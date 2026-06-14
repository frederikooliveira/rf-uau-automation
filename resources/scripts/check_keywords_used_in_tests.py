"""Report resource keywords that are not called from files under tests/."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from robot.api.parsing import ModelVisitor, get_model


def normalize_keyword_name(name: str) -> str:
    """Normalize Robot keyword name according to matching rules."""
    return "".join(ch for ch in name.lower() if ch not in {" ", "_"})


@dataclass
class KeywordDefinition:
    name: str
    normalized_name: str
    file: Path
    line: int


class ResourceKeywordCollector(ModelVisitor):
    def __init__(self, source_file: Path) -> None:
        self.source_file = source_file
        self.in_keyword_section = False
        self.definitions: list[KeywordDefinition] = []

    def visit_KeywordSection(self, node):  # noqa: N802
        previous = self.in_keyword_section
        self.in_keyword_section = True
        self.generic_visit(node)
        self.in_keyword_section = previous

    def visit_KeywordName(self, node):  # noqa: N802
        if not self.in_keyword_section:
            return
        raw_name = (getattr(node, "name", "") or "").strip()
        if not raw_name:
            return
        self.definitions.append(
            KeywordDefinition(
                name=raw_name,
                normalized_name=normalize_keyword_name(raw_name),
                file=self.source_file,
                line=getattr(node, "lineno", 0) or 0,
            )
        )


class TestCallCollector(ModelVisitor):
    def __init__(self) -> None:
        self.called_keywords: set[str] = set()

    def _record(self, keyword_name: str) -> None:
        cleaned = (keyword_name or "").strip()
        if not cleaned:
            return
        normalized = normalize_keyword_name(cleaned)
        if normalized:
            self.called_keywords.add(normalized)

    def visit_KeywordCall(self, node):  # noqa: N802
        self._record(getattr(node, "keyword", ""))
        self.generic_visit(node)

    def visit_Setup(self, node):  # noqa: N802
        self._record(getattr(node, "name", ""))
        self.generic_visit(node)

    def visit_Teardown(self, node):  # noqa: N802
        self._record(getattr(node, "name", ""))
        self.generic_visit(node)

    def visit_SuiteSetup(self, node):  # noqa: N802
        self._record(getattr(node, "name", ""))
        self.generic_visit(node)

    def visit_SuiteTeardown(self, node):  # noqa: N802
        self._record(getattr(node, "name", ""))
        self.generic_visit(node)

    def visit_TestSetup(self, node):  # noqa: N802
        self._record(getattr(node, "name", ""))
        self.generic_visit(node)

    def visit_TestTeardown(self, node):  # noqa: N802
        self._record(getattr(node, "name", ""))
        self.generic_visit(node)


def iter_robot_files(root: Path, suffixes: tuple[str, ...]) -> Iterable[Path]:
    if not root.exists():
        return []
    return sorted(
        path
        for suffix in suffixes
        for path in root.rglob(f"*{suffix}")
        if path.is_file()
    )


def collect_resource_keyword_definitions(resources_dir: Path) -> list[KeywordDefinition]:
    definitions: list[KeywordDefinition] = []
    for file_path in iter_robot_files(resources_dir, (".resource",)):
        model = get_model(str(file_path))
        collector = ResourceKeywordCollector(file_path)
        collector.visit(model)
        definitions.extend(collector.definitions)
    return definitions


def collect_called_keywords_from_tests(tests_dir: Path) -> set[str]:
    called: set[str] = set()
    for file_path in iter_robot_files(tests_dir, (".robot", ".resource")):
        model = get_model(str(file_path))
        collector = TestCallCollector()
        collector.visit(model)
        called.update(collector.called_keywords)
    return called


def make_relative(path: Path, base: Path) -> str:
    try:
        return str(path.relative_to(base))
    except ValueError:
        return str(path)


def run(resources_dir: Path, tests_dir: Path, output_format: str) -> int:
    workspace_root = Path.cwd()

    definitions = collect_resource_keyword_definitions(resources_dir)
    called_by_tests = collect_called_keywords_from_tests(tests_dir)

    unused = [
        item
        for item in definitions
        if item.normalized_name and item.normalized_name not in called_by_tests
    ]

    if output_format == "json":
        payload = {
            "resources_dir": make_relative(resources_dir, workspace_root),
            "tests_dir": make_relative(tests_dir, workspace_root),
            "total_resource_keywords": len(definitions),
            "keywords_called_from_tests": len(called_by_tests),
            "unused_count": len(unused),
            "unused": [
                {
                    "name": item.name,
                    "file": make_relative(item.file, workspace_root),
                    "line": item.line,
                }
                for item in unused
            ],
        }
        print(json.dumps(payload, ensure_ascii=True, indent=2))
    else:
        print(f"[CHECKER] resources: {make_relative(resources_dir, workspace_root)}")
        print(f"[CHECKER] tests: {make_relative(tests_dir, workspace_root)}")
        print(f"[CHECKER] keywords em resources: {len(definitions)}")
        print(f"[CHECKER] keywords chamadas em tests: {len(called_by_tests)}")
        print(f"[CHECKER] keywords sem uso em tests: {len(unused)}")

        if unused:
            print("\n[CHECKER] Lista de keywords sem uso em tests:")
            for item in sorted(unused, key=lambda x: (str(x.file), x.line, x.name.lower())):
                rel = make_relative(item.file, workspace_root)
                print(f"- {item.name} ({rel}:{item.line})")

    return 1 if unused else 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Lista keywords de resources nao chamadas dentro da pasta tests"
    )
    parser.add_argument("--resources-dir", default="resources", help="Pasta de resources")
    parser.add_argument("--tests-dir", default="tests", help="Pasta de testes")
    parser.add_argument(
        "--format",
        choices=("text", "json"),
        default="text",
        help="Formato de saida",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    resources_dir = Path(args.resources_dir)
    tests_dir = Path(args.tests_dir)

    if not resources_dir.exists():
        print(f"[CHECKER] Pasta nao encontrada: {resources_dir}", file=sys.stderr)
        return 2

    if not tests_dir.exists():
        print(f"[CHECKER] Pasta nao encontrada: {tests_dir}", file=sys.stderr)
        return 2

    return run(resources_dir=resources_dir, tests_dir=tests_dir, output_format=args.format)


if __name__ == "__main__":
    raise SystemExit(main())
