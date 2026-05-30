"""Probe de grid UauXT baseado em Win32/pywinauto.

Objetivo:
- Descobrir o componente de grid por classe/parent chain.
- Registrar metadados estaveis (handle, rect, class, depth).
- Ler linhas por atalho de teclado + clipboard (fallback robusto).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import time
import warnings
from dataclasses import dataclass
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

import pywinauto
from pywinauto import clipboard
from pywinauto import keyboard

warnings.filterwarnings(
    "ignore",
    message=r"32-bit application should be automated using 32-bit Python.*",
    category=UserWarning,
)

DEFAULT_TOKENS = ("TG80", "C1Grid", "GridOleDB", "grid")
DEFAULT_MAX_DEPTH = 30
DEFAULT_MAX_NODES = 4000


@dataclass
class GridCandidate:
    handle: int
    class_name: str
    text: str
    depth: int
    left: int
    top: int
    right: int
    bottom: int
    visible: bool
    enabled: bool
    child_count: int
    parent_chain: str
    score: int


def _safe(fn, default=None):
    try:
        return fn()
    except Exception:
        return default


def _iter_tree(root, max_depth: int, max_nodes: int) -> Iterable[Tuple[Any, int]]:
    stack: List[Tuple[Any, int]] = [(root, 0)]
    seen: set[str] = set()
    visited = 0

    while stack:
        ctrl, depth = stack.pop()
        uid = _control_uid(ctrl)
        if uid in seen:
            continue
        seen.add(uid)
        yield ctrl, depth
        visited += 1
        if visited >= max_nodes or depth >= max_depth:
            continue

        children = _safe(ctrl.children, [])
        for child in reversed(children):
            stack.append((child, depth + 1))


def _control_uid(ctrl: Any) -> str:
    handle = _safe(lambda: ctrl.handle, None)
    if handle not in (None, ""):
        return f"h:{handle}"

    cls = str(_safe(ctrl.class_name, ""))
    txt = str(_safe(ctrl.window_text, ""))
    return f"f:{cls}|{txt}"


def _parent_chain(ctrl: Any, max_levels: int = 6) -> str:
    chain: List[str] = []
    current = ctrl
    for _ in range(max_levels):
        parent = _safe(current.parent, None)
        if not parent:
            break
        p_cls = str(_safe(parent.class_name, ""))
        p_txt = str(_safe(parent.window_text, ""))
        chain.append(f"{p_cls}:{p_txt}")
        current = parent
    return " > ".join(chain)


def _connect_uauxt_window(title_regex: Optional[str] = None):
    app = pywinauto.Application(backend="win32").connect(path="UauXT.exe")
    windows = _safe(app.windows, [])

    if title_regex:
        pattern = re.compile(title_regex, re.IGNORECASE)
        for window in windows:
            title = str(_safe(window.window_text, ""))
            if pattern.search(title):
                return app, window

    for window in windows:
        title = str(_safe(window.window_text, ""))
        if "UAUXT - Vers" in title:
            return app, window

    return app, app.top_window()


def _score_candidate(
    ctrl: Any,
    depth: int,
    target_text: str,
) -> int:
    score = 0
    if _safe(ctrl.is_visible, False):
        score += 1000
    if _safe(ctrl.is_enabled, False):
        score += 300

    child_count = len(_safe(ctrl.children, []))
    score += min(child_count, 400)

    c_text = str(_safe(ctrl.window_text, ""))
    chain = _parent_chain(ctrl, max_levels=8)

    if target_text:
        target = target_text.lower()
        if target in c_text.lower():
            score += 1500
        if target in chain.lower():
            score += 1800

    score -= depth * 3
    return score


def find_grid(
    target_text: str,
    class_tokens: Sequence[str],
    preferred_index: int,
    title_regex: Optional[str],
) -> Dict[str, Any]:
    _app, root = _connect_uauxt_window(title_regex=title_regex)

    hits: List[GridCandidate] = []
    tokens_l = [t.lower() for t in class_tokens if t]

    for ctrl, depth in _iter_tree(root, DEFAULT_MAX_DEPTH, DEFAULT_MAX_NODES):
        class_name = str(_safe(ctrl.class_name, ""))
        class_l = class_name.lower()
        if not any(token in class_l for token in tokens_l):
            continue

        handle = _safe(lambda: int(ctrl.handle), 0)
        if not handle:
            continue

        rect = _safe(ctrl.rectangle, None)
        if not rect:
            continue

        text = str(_safe(ctrl.window_text, ""))
        visible = bool(_safe(ctrl.is_visible, False))
        enabled = bool(_safe(ctrl.is_enabled, False))
        child_count = len(_safe(ctrl.children, []))
        chain = _parent_chain(ctrl)
        score = _score_candidate(ctrl, depth, target_text)

        hits.append(
            GridCandidate(
                handle=handle,
                class_name=class_name,
                text=text,
                depth=depth,
                left=int(rect.left),
                top=int(rect.top),
                right=int(rect.right),
                bottom=int(rect.bottom),
                visible=visible,
                enabled=enabled,
                child_count=child_count,
                parent_chain=chain,
                score=score,
            )
        )

    if not hits:
        return {
            "ok": False,
            "message": "Nenhum grid encontrado pelos tokens de classe.",
            "tokens": list(class_tokens),
            "target_text": target_text,
            "window": str(_safe(root.window_text, "")),
        }

    ranked = sorted(hits, key=lambda x: x.score, reverse=True)

    selected = None
    if 0 <= preferred_index < len(ranked):
        selected = ranked[preferred_index]
    else:
        selected = ranked[0]

    return {
        "ok": True,
        "window": str(_safe(root.window_text, "")),
        "target_text": target_text,
        "tokens": list(class_tokens),
        "count": len(ranked),
        "selected": {
            "handle": selected.handle,
            "class_name": selected.class_name,
            "text": selected.text,
            "depth": selected.depth,
            "left": selected.left,
            "top": selected.top,
            "right": selected.right,
            "bottom": selected.bottom,
            "width": selected.right - selected.left,
            "height": selected.bottom - selected.top,
            "visible": selected.visible,
            "enabled": selected.enabled,
            "child_count": selected.child_count,
            "parent_chain": selected.parent_chain,
            "score": selected.score,
        },
        "top_candidates": [
            {
                "handle": item.handle,
                "class_name": item.class_name,
                "depth": item.depth,
                "left": item.left,
                "top": item.top,
                "right": item.right,
                "bottom": item.bottom,
                "visible": item.visible,
                "enabled": item.enabled,
                "child_count": item.child_count,
                "score": item.score,
                "parent_chain": item.parent_chain,
            }
            for item in ranked[:10]
        ],
    }


def _connect_by_handle(handle: int):
    app = pywinauto.Application(backend="win32").connect(path="UauXT.exe")
    return app.window(handle=handle)


def _parse_clipboard_lines(raw: str, max_rows: int) -> List[str]:
    lines = [line.strip() for line in str(raw).splitlines()]
    lines = [line for line in lines if line]
    if max_rows > 0:
        return lines[:max_rows]
    return lines


def _is_noise_line(line: str) -> bool:
    text = str(line).strip()
    if not text:
        return True
    # Ruido comum quando algum warning/log externo para no clipboard por engano.
    if text.startswith("[UAUXT-GRID] stderr:"):
        return True
    if text.startswith("[UAUXT-GRID]"):
        return True
    if text.startswith("[DIAG-GRID]"):
        return True
    if "UserWarning:" in text and "32-bit application should be automated" in text:
        return True
    if text.endswith("warnings.warn("):
        return True
    return False


def _copy_grid_rows(ctrl: Any, max_rows: int) -> List[str]:
    previous_raw = _safe(clipboard.GetData, "") or ""

    for _ in range(3):
        _safe(ctrl.set_focus)
        _safe(ctrl.click_input)
        keyboard.send_keys("^a")
        keyboard.send_keys("^c")
        time.sleep(0.3)

        raw = _safe(clipboard.GetData, "") or ""
        if not str(raw).strip() and str(previous_raw).strip():
            raw = previous_raw
        rows = _parse_clipboard_lines(str(raw), max_rows=max_rows)
        rows = [row for row in rows if not _is_noise_line(row)]
        if rows:
            return rows

    return []


def _send_key_repeat(key_name: str, count: int, delay_s: float = 0.06) -> None:
    steps = max(0, int(count))
    for _ in range(steps):
        keyboard.send_keys("{" + key_name + "}")
        time.sleep(delay_s)


def _commit_current_cell_edit() -> None:
    # Forca commit da celula atual ciclando para a celula ao lado e retornando.
    keyboard.send_keys("{RIGHT}")
    time.sleep(0.05)
    keyboard.send_keys("{LEFT}")
    time.sleep(0.05)


def navigate_grid_keyboard(
    handle: int,
    page_up_times: int,
    row_steps: int,
    col_steps: int,
    row_direction: str,
    col_direction: str,
) -> Dict[str, Any]:
    ctrl = _connect_by_handle(handle)

    row_dir = str(row_direction or "down").strip().lower()
    col_dir = str(col_direction or "right").strip().lower()
    if row_dir not in ("down", "up"):
        raise ValueError("row_direction deve ser 'down' ou 'up'.")
    if col_dir not in ("right", "left"):
        raise ValueError("col_direction deve ser 'right' ou 'left'.")

    _safe(ctrl.set_focus)
    _safe(ctrl.click_input)
    time.sleep(0.15)

    _send_key_repeat("PGUP", max(1, int(page_up_times)), delay_s=0.12)
    keyboard.send_keys("{HOME}")
    time.sleep(0.08)

    if int(row_steps) > 0:
        _send_key_repeat("DOWN" if row_dir == "down" else "UP", int(row_steps))

    if int(col_steps) > 0:
        _send_key_repeat("RIGHT" if col_dir == "right" else "LEFT", int(col_steps))

    return {
        "ok": True,
        "handle": handle,
        "action": "navigate-grid",
        "page_up_times": max(1, int(page_up_times)),
        "row_steps": int(row_steps),
        "col_steps": int(col_steps),
        "row_direction": row_dir,
        "col_direction": col_dir,
    }


def fill_grid_cells(
    handle: int,
    page_up_times: int,
    start_row: int,
    col_index: int,
    rows_count: int,
    value: str,
) -> Dict[str, Any]:
    ctrl = _connect_by_handle(handle)

    start_row_0 = max(0, int(start_row))
    col_index_1 = max(1, int(col_index))
    rows_total = max(1, int(rows_count))
    text_value = str(value)

    _safe(ctrl.set_focus)
    _safe(ctrl.click_input)
    time.sleep(0.15)

    _send_key_repeat("PGUP", max(1, int(page_up_times)), delay_s=0.12)
    keyboard.send_keys("{HOME}")
    time.sleep(0.08)

    if start_row_0 > 0:
        _send_key_repeat("DOWN", start_row_0)

    if col_index_1 > 1:
        _send_key_repeat("RIGHT", col_index_1 - 1)

    for i in range(rows_total):
        keyboard.send_keys(text_value, with_spaces=True, pause=0.02)
        time.sleep(0.05)
        _commit_current_cell_edit()
        if i < rows_total - 1:
            keyboard.send_keys("{DOWN}")
            time.sleep(0.06)

    return {
        "ok": True,
        "handle": handle,
        "action": "fill-grid-cells",
        "page_up_times": max(1, int(page_up_times)),
        "start_row": start_row_0,
        "col_index": col_index_1,
        "rows_count": rows_total,
        "value": text_value,
    }


def set_grid_cell(
    handle: int,
    page_up_times: int,
    row_index: int,
    col_index: int,
    value: str,
) -> Dict[str, Any]:
    data = fill_grid_cells(
        handle=handle,
        page_up_times=page_up_times,
        start_row=row_index,
        col_index=col_index,
        rows_count=1,
        value=value,
    )
    data["action"] = "set-grid-cell"
    data["row_index"] = max(0, int(row_index))
    return data


def fill_grid_cells_by_row_indexes(
    handle: int,
    page_up_times: int,
    col_index: int,
    row_indexes: Sequence[int],
    value: str,
    move_delay_ms: int,
    type_delay_ms: int,
    commit_delay_ms: int,
) -> Dict[str, Any]:
    ctrl = _connect_by_handle(handle)

    col_index_1 = max(1, int(col_index))
    text_value = str(value)
    normalized = sorted({max(0, int(idx)) for idx in row_indexes})
    if not normalized:
        raise ValueError("row_indexes deve conter ao menos um indice de linha.")

    move_delay_s = max(0.0, float(move_delay_ms) / 1000.0)
    type_delay_s = max(0.0, float(type_delay_ms) / 1000.0)
    commit_delay_s = max(0.0, float(commit_delay_ms) / 1000.0)

    _safe(ctrl.set_focus)
    _safe(ctrl.click_input)
    time.sleep(0.15)

    _send_key_repeat("PGUP", max(1, int(page_up_times)), delay_s=0.12)
    keyboard.send_keys("{HOME}")
    time.sleep(0.08)

    first_row = normalized[0]
    if first_row > 0:
        _send_key_repeat("DOWN", first_row)

    if col_index_1 > 1:
        _send_key_repeat("RIGHT", col_index_1 - 1)

    current_pointer = first_row
    touched_rows: List[int] = []
    total_targets = len(normalized)

    for idx, target_row in enumerate(normalized):
        while current_pointer < target_row:
            keyboard.send_keys("{DOWN}")
            current_pointer += 1
            time.sleep(move_delay_s)

        keyboard.send_keys(text_value, with_spaces=True, pause=0.02)
        time.sleep(type_delay_s)
        touched_rows.append(target_row)

        # DOWN confirma o valor digitado e posiciona na proxima linha.
        # Enviado sempre, inclusive apos a ultima celula, para garantir que
        # a celula saia do modo edicao antes do processo encerrar.
        keyboard.send_keys("{DOWN}")
        current_pointer += 1
        time.sleep(commit_delay_s)

    return {
        "ok": True,
        "handle": handle,
        "action": "fill-grid-indexes",
        "page_up_times": max(1, int(page_up_times)),
        "col_index": col_index_1,
        "row_indexes": normalized,
        "touched_rows": touched_rows,
        "rows_count": len(normalized),
        "value": text_value,
        "commit_strategy": "always-down",
        "move_delay_ms": int(move_delay_ms),
        "type_delay_ms": int(type_delay_ms),
        "commit_delay_ms": int(commit_delay_ms),
    }


def click_grid_cell_button(
    handle: int,
    page_up_times: int,
    row_index: int,
    col_index: int,
    interaction_mode: str,
) -> Dict[str, Any]:
    ctrl = _connect_by_handle(handle)

    row_index_0 = max(0, int(row_index))
    col_index_1 = max(1, int(col_index))
    mode = str(interaction_mode or "right-corner-click").strip().lower()
    if mode not in ("right-corner-click", "alt-down", "double-click"):
        raise ValueError("interaction_mode deve ser 'right-corner-click', 'alt-down' ou 'double-click'.")

    _safe(ctrl.set_focus)
    _safe(ctrl.click_input)
    time.sleep(0.15)

    _send_key_repeat("PGUP", max(1, int(page_up_times)), delay_s=0.12)
    keyboard.send_keys("{HOME}")
    time.sleep(0.08)

    if row_index_0 > 0:
        _send_key_repeat("DOWN", row_index_0)

    if col_index_1 > 1:
        _send_key_repeat("RIGHT", col_index_1 - 1)

    click_x = 0
    click_y = 0
    click_error = ""
    click_ok = True

    if mode == "right-corner-click":
        rect = _safe(ctrl.rectangle, None)
        if not rect:
            raise RuntimeError("Nao foi possivel obter retangulo do grid para clique por coordenada.")

        grid_width = max(1, int(rect.right) - int(rect.left))
        grid_height = max(1, int(rect.bottom) - int(rect.top))
        cell_width = max(1, int(grid_width / max(col_index_1, 1)))
        cell_height = max(1, min(26, int(grid_height / max(row_index_0 + 12, 12))))
        click_x = max(6, int(col_index_1 * cell_width) - 6)
        click_y = max(10, int(24 + (row_index_0 * cell_height) + (cell_height / 2)))

        time.sleep(0.08)
        try:
            ctrl.click_input(coords=(click_x, click_y))
        except Exception as exc:
            click_ok = False
            click_error = str(exc)
        time.sleep(0.10)
    elif mode == "double-click":
        rect = _safe(ctrl.rectangle, None)
        if not rect:
            raise RuntimeError("Nao foi possivel obter retangulo do grid para duplo clique por coordenada.")

        grid_width = max(1, int(rect.right) - int(rect.left))
        grid_height = max(1, int(rect.bottom) - int(rect.top))
        cell_height = max(1, min(26, int(grid_height / max(row_index_0 + 12, 12))))
        click_x = max(6, int(grid_width / 2))
        click_y = max(10, int(24 + (row_index_0 * cell_height) + (cell_height / 2)))

        time.sleep(0.08)
        try:
            ctrl.double_click_input(coords=(click_x, click_y))
        except Exception as exc:
            click_ok = False
            click_error = str(exc)
        time.sleep(0.20)
    else:
        time.sleep(0.08)
        try:
            keyboard.send_keys("%{DOWN}")
        except Exception as exc:
            click_ok = False
            click_error = str(exc)
        time.sleep(0.10)

    return {
        "ok": bool(click_ok),
        "handle": handle,
        "action": "click-cell-button",
        "page_up_times": max(1, int(page_up_times)),
        "row_index": row_index_0,
        "col_index": col_index_1,
        "interaction_mode": mode,
        "click_x": int(click_x),
        "click_y": int(click_y),
        "click_ok": bool(click_ok),
        "error": click_error,
    }


def get_grid_cell_value(
    handle: int,
    page_up_times: int,
    row_index: int,
    col_index: int,
) -> Dict[str, Any]:
    ctrl = _connect_by_handle(handle)

    row_index_0 = max(0, int(row_index))
    col_index_1 = max(1, int(col_index))

    _safe(ctrl.set_focus)
    _safe(ctrl.click_input)
    time.sleep(0.15)

    _send_key_repeat("PGUP", max(1, int(page_up_times)), delay_s=0.12)
    keyboard.send_keys("{HOME}")
    time.sleep(0.08)

    if row_index_0 > 0:
        _send_key_repeat("DOWN", row_index_0)
    if col_index_1 > 1:
        _send_key_repeat("RIGHT", col_index_1 - 1)

    time.sleep(0.15)

    # Entra em modo edicao para expor o valor no campo de edicao, depois copia.
    previous_raw = _safe(clipboard.GetData, "") or ""
    keyboard.send_keys("{F2}")
    time.sleep(0.20)
    keyboard.send_keys("^a")
    time.sleep(0.08)
    keyboard.send_keys("^c")
    time.sleep(0.25)

    raw = str(_safe(clipboard.GetData, "") or "")
    # Se nada mudou no clipboard, tenta direto sem F2.
    if not raw.strip() or raw.strip() == str(previous_raw).strip():
        keyboard.send_keys("{ESCAPE}")
        time.sleep(0.12)
        keyboard.send_keys("^c")
        time.sleep(0.25)
        raw = str(_safe(clipboard.GetData, "") or "")

    # Cancela edicao sem alterar valor.
    keyboard.send_keys("{ESCAPE}")
    time.sleep(0.10)

    cell_value = raw.strip().splitlines()[0].strip() if raw.strip() else ""

    return {
        "ok": True,
        "handle": handle,
        "action": "get-cell",
        "row_index": row_index_0,
        "col_index": col_index_1,
        "value": cell_value,
        "raw": raw.strip(),
    }


def refresh_grid_footer_via_caption(handle: int, page_up_times: int) -> Dict[str, Any]:
    ctrl = _connect_by_handle(handle)

    _safe(ctrl.set_focus)
    time.sleep(0.15)

    _send_key_repeat("PGUP", max(1, int(page_up_times)), delay_s=0.12)
    keyboard.send_keys("{HOME}")
    time.sleep(0.08)
    keyboard.send_keys("{UP}")
    time.sleep(0.10)

    # Duplo clique na faixa superior do grid (caption/header) para atualizar o rodape.
    double_click_ok = _safe(lambda: ctrl.double_click_input(coords=(120, 12)), False)

    time.sleep(0.25)
    return {
        "ok": True,
        "handle": handle,
        "action": "refresh-grid-footer",
        "page_up_times": max(1, int(page_up_times)),
        "double_click_ok": bool(double_click_ok),
    }


def read_grid_by_clipboard(handle: int, contains: str, max_rows: int, page_downs: int) -> Dict[str, Any]:
    ctrl = _connect_by_handle(handle)

    page_downs = max(0, int(page_downs))
    rows: List[str] = []
    seen = set()

    for page in range(page_downs + 1):
        page_rows = _copy_grid_rows(ctrl, max_rows=0)
        for row in page_rows:
            if row in seen:
                continue
            seen.add(row)
            rows.append(row)
            if max_rows > 0 and len(rows) >= max_rows:
                break

        if max_rows > 0 and len(rows) >= max_rows:
            break

        if page < page_downs:
            keyboard.send_keys("{PGDN}")
            time.sleep(0.2)

    if max_rows > 0:
        rows = rows[:max_rows]

    found = False
    if contains:
        needle = contains.lower()
        found = any(needle in row.lower() for row in rows)

    return {
        "ok": True,
        "handle": handle,
        "rows_found": len(rows),
        "contains": contains,
        "contains_found": found,
        "rows": rows,
    }


def _emit(data: Dict[str, Any], pretty: bool):
    if pretty:
        print(json.dumps(data, ensure_ascii=True, indent=2))
    else:
        print(json.dumps(data, ensure_ascii=True))


def _parse_tokens(raw: str) -> List[str]:
    if not raw:
        return list(DEFAULT_TOKENS)
    return [part.strip() for part in raw.split(",") if part.strip()]


def _parse_row_indexes(raw: str) -> List[int]:
    if not raw:
        return []
    parts = [part.strip() for part in str(raw).split(",") if part.strip()]
    return [int(part) for part in parts]


def main() -> int:
    parser = argparse.ArgumentParser(description="Probe de grid UauXT por pywinauto")
    subparsers = parser.add_subparsers(dest="command", required=True)

    parser_find = subparsers.add_parser("find-grid", help="Localiza grid por classe e contexto")
    parser_find.add_argument("--target-text", default="Contas a Pagar")
    parser_find.add_argument("--tokens", default=",".join(DEFAULT_TOKENS))
    parser_find.add_argument("--grid-index", type=int, default=0)
    parser_find.add_argument("--window-title-regex", default="")
    parser_find.add_argument("--pretty", action="store_true")

    parser_read = subparsers.add_parser("read-grid", help="Le linhas por clipboard usando handle")
    parser_read.add_argument("--handle", type=int, required=True)
    parser_read.add_argument("--contains", default="")
    parser_read.add_argument("--max-rows", type=int, default=50)
    parser_read.add_argument("--page-downs", type=int, default=0)
    parser_read.add_argument("--pretty", action="store_true")

    parser_nav = subparsers.add_parser("navigate-grid", help="Foca grid e navega via teclado")
    parser_nav.add_argument("--handle", type=int, required=True)
    parser_nav.add_argument("--page-up-times", type=int, default=1)
    parser_nav.add_argument("--row-steps", type=int, default=0)
    parser_nav.add_argument("--col-steps", type=int, default=0)
    parser_nav.add_argument("--row-direction", default="down")
    parser_nav.add_argument("--col-direction", default="right")
    parser_nav.add_argument("--pretty", action="store_true")

    parser_fill = subparsers.add_parser("fill-grid", help="Preenche valor em linhas consecutivas de uma coluna")
    parser_fill.add_argument("--handle", type=int, required=True)
    parser_fill.add_argument("--page-up-times", type=int, default=1)
    parser_fill.add_argument("--start-row", type=int, default=0)
    parser_fill.add_argument("--col-index", type=int, required=True)
    parser_fill.add_argument("--rows-count", type=int, default=1)
    parser_fill.add_argument("--value", required=True)
    parser_fill.add_argument("--pretty", action="store_true")

    parser_set = subparsers.add_parser("set-cell", help="Preenche valor em uma celula especifica (linha/coluna)")
    parser_set.add_argument("--handle", type=int, required=True)
    parser_set.add_argument("--page-up-times", type=int, default=1)
    parser_set.add_argument("--row-index", type=int, required=True)
    parser_set.add_argument("--col-index", type=int, required=True)
    parser_set.add_argument("--value", required=True)
    parser_set.add_argument("--pretty", action="store_true")

    parser_indexes = subparsers.add_parser("fill-grid-indexes", help="Preenche valor em coluna para lista de indices de linha")
    parser_indexes.add_argument("--handle", type=int, required=True)
    parser_indexes.add_argument("--page-up-times", type=int, default=1)
    parser_indexes.add_argument("--col-index", type=int, required=True)
    parser_indexes.add_argument("--row-indexes", required=True)
    parser_indexes.add_argument("--value", required=True)
    parser_indexes.add_argument("--move-delay-ms", type=int, default=120)
    parser_indexes.add_argument("--type-delay-ms", type=int, default=80)
    parser_indexes.add_argument("--commit-delay-ms", type=int, default=350)
    parser_indexes.add_argument("--pretty", action="store_true")

    parser_get = subparsers.add_parser("get-cell", help="Le valor de uma celula especifica (linha/coluna) via clipboard")
    parser_get.add_argument("--handle", type=int, required=True)
    parser_get.add_argument("--page-up-times", type=int, default=1)
    parser_get.add_argument("--row-index", type=int, required=True)
    parser_get.add_argument("--col-index", type=int, required=True)
    parser_get.add_argument("--pretty", action="store_true")

    parser_click = subparsers.add_parser("click-cell-button", help="Navega para celula e aciona botao da celula")
    parser_click.add_argument("--handle", type=int, required=True)
    parser_click.add_argument("--page-up-times", type=int, default=1)
    parser_click.add_argument("--row-index", type=int, required=True)
    parser_click.add_argument("--col-index", type=int, required=True)
    parser_click.add_argument("--interaction-mode", default="right-corner-click")
    parser_click.add_argument("--pretty", action="store_true")

    parser_refresh = subparsers.add_parser("refresh-footer", help="Atualiza rodape via caption (HOME + UP + duplo clique)")
    parser_refresh.add_argument("--handle", type=int, required=True)
    parser_refresh.add_argument("--page-up-times", type=int, default=1)
    parser_refresh.add_argument("--pretty", action="store_true")

    args = parser.parse_args()

    try:
        if args.command == "find-grid":
            tokens = _parse_tokens(args.tokens)
            title_regex = args.window_title_regex or None
            data = find_grid(
                target_text=args.target_text,
                class_tokens=tokens,
                preferred_index=args.grid_index,
                title_regex=title_regex,
            )
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        if args.command == "read-grid":
            data = read_grid_by_clipboard(
                handle=int(args.handle),
                contains=args.contains,
                max_rows=int(args.max_rows),
                page_downs=int(args.page_downs),
            )
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        if args.command == "navigate-grid":
            data = navigate_grid_keyboard(
                handle=int(args.handle),
                page_up_times=int(args.page_up_times),
                row_steps=int(args.row_steps),
                col_steps=int(args.col_steps),
                row_direction=args.row_direction,
                col_direction=args.col_direction,
            )
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        if args.command == "fill-grid":
            data = fill_grid_cells(
                handle=int(args.handle),
                page_up_times=int(args.page_up_times),
                start_row=int(args.start_row),
                col_index=int(args.col_index),
                rows_count=int(args.rows_count),
                value=args.value,
            )
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        if args.command == "set-cell":
            data = set_grid_cell(
                handle=int(args.handle),
                page_up_times=int(args.page_up_times),
                row_index=int(args.row_index),
                col_index=int(args.col_index),
                value=args.value,
            )
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        if args.command == "fill-grid-indexes":
            data = fill_grid_cells_by_row_indexes(
                handle=int(args.handle),
                page_up_times=int(args.page_up_times),
                col_index=int(args.col_index),
                row_indexes=_parse_row_indexes(args.row_indexes),
                value=args.value,
                move_delay_ms=int(args.move_delay_ms),
                type_delay_ms=int(args.type_delay_ms),
                commit_delay_ms=int(args.commit_delay_ms),
            )
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        if args.command == "get-cell":
            data = get_grid_cell_value(
                handle=int(args.handle),
                page_up_times=int(args.page_up_times),
                row_index=int(args.row_index),
                col_index=int(args.col_index),
            )
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        if args.command == "click-cell-button":
            data = click_grid_cell_button(
                handle=int(args.handle),
                page_up_times=int(args.page_up_times),
                row_index=int(args.row_index),
                col_index=int(args.col_index),
                interaction_mode=args.interaction_mode,
            )
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        if args.command == "refresh-footer":
            data = refresh_grid_footer_via_caption(
                handle=int(args.handle),
                page_up_times=int(args.page_up_times),
            )
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        print(json.dumps({"ok": False, "message": "Comando invalido."}))
        return 2
    except Exception as exc:
        print(
            json.dumps(
                {
                    "ok": False,
                    "message": "Erro ao executar probe de grid.",
                    "error": str(exc),
                },
                ensure_ascii=True,
            ),
            file=sys.stderr,
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
