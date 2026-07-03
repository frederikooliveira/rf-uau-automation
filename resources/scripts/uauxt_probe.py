"""Probe Win32/pywinauto para automacao de componentes nativos do UauXT.

Seções:
  GRID     -- Descoberta, leitura e interação com grids TG80/C1Grid/GridOleDB.
  TOOLBAR  -- Clique em botões de toolbar VB6 (msvb_lib_toolbar) via TB_GETITEMRECT.

Convenções:
- Cada seção é demarcada por um banner de linha.  Se o arquivo crescer muito
  (ex: treeview, menus nativos), extrair a seção para um módulo dedicado.
- Todas as funções públicas retornam Dict[str, Any] com chave 'ok' (bool).
- Helpers internos usam prefixo '_' e não devem ser chamados diretamente.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import time
import warnings
import ctypes
import ctypes.wintypes
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

# ════════════════════════════════════════════════════════════════════════════════
# GRID  --  TG80 / C1Grid / GridOleDB
# ════════════════════════════════════════════════════════════════════════════════


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


def _collect_control_identity(ctrl: Any) -> Dict[str, Any]:
    """Coleta dados básicos de identidade de um controle Win32/UIA para inspeção."""
    handle = _safe(lambda: int(ctrl.handle), None)
    cls_name = _safe(lambda: ctrl.class_name(), "")
    txt = _safe(lambda: ctrl.window_text(), "")
    visible = bool(_safe(lambda: ctrl.is_visible(), False))
    enabled = bool(_safe(lambda: ctrl.is_enabled(), False))

    automation_id = None
    for attr in ("automation_id", "control_id"):
        value = _safe(lambda: getattr(ctrl, attr), None)
        if value is None:
            continue
        if callable(value):
            try:
                value = value()
            except Exception:
                value = None
        if value not in (None, ""):
            automation_id = value
            break

    if automation_id is None:
        # Tenta materializar o valor via UIA/pywinauto quando o controle vier de um wrapper compatível.
        try:
            wrapper = getattr(ctrl, "element_info", None)
            if wrapper is not None:
                automation_id = _safe(lambda: getattr(wrapper, "automation_id", None), None)
        except Exception:
            automation_id = None

    return {
        "handle": handle,
        "class_name": cls_name,
        "text": txt,
        "automation_id": automation_id,
        "visible": visible,
        "enabled": enabled,
    }


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
    if mode not in ("right-corner-click", "alt-down", "double-click", "select-row", "check-row"):
        raise ValueError("interaction_mode deve ser 'right-corner-click', 'alt-down', 'double-click', 'select-row' ou 'check-row'.")

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
    elif mode == "select-row":
        rect = _safe(ctrl.rectangle, None)
        if not rect:
            raise RuntimeError("Nao foi possivel obter retangulo do grid para selecionar linha por coordenada.")

        grid_width = max(1, int(rect.right) - int(rect.left))
        grid_height = max(1, int(rect.bottom) - int(rect.top))
        cell_height = max(1, min(26, int(grid_height / max(row_index_0 + 12, 12))))
        click_x = max(6, int(grid_width / 4))
        click_y = max(10, int(24 + (row_index_0 * cell_height) + (cell_height / 2)))

        time.sleep(0.08)
        try:
            ctrl.click_input(coords=(click_x, click_y))
        except Exception as exc:
            click_ok = False
            click_error = str(exc)
        time.sleep(0.10)
    elif mode == "check-row":
        # Clica na coluna 0 (seletor/checkbox do grid) — x fixo proximo a borda esquerda.
        rect = _safe(ctrl.rectangle, None)
        if not rect:
            raise RuntimeError("Nao foi possivel obter retangulo do grid para check-row.")

        grid_height = max(1, int(rect.bottom) - int(rect.top))
        cell_height = max(1, min(26, int(grid_height / max(row_index_0 + 12, 12))))
        click_x = 10  # coluna 0 (checkbox/seletor) sempre no canto esquerdo
        click_y = max(10, int(24 + (row_index_0 * cell_height) + (cell_height / 2)))

        time.sleep(0.08)
        try:
            ctrl.click_input(coords=(click_x, click_y))
        except Exception as exc:
            click_ok = False
            click_error = str(exc)
        time.sleep(0.10)
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


# ════════════════════════════════════════════════════════════════════════════════
# TOOLBAR  --  msvb_lib_toolbar (VB6 ActiveX)
# Botoes VB6 nao expoe nomes via UIA/MSAA/TB_GETBUTTONTEXTW.
# Identificar botoes pelo indice 0-based (TB_GETITEMRECT cross-process).
# Indices mapeados em resources/data/*_data.resource.
# ════════════════════════════════════════════════════════════════════════════════

def list_controls(class_filter: str = "", text_filter: str = "") -> Dict[str, Any]:
    """Enumera todos os controles filhos da janela UauXT ativa.

    Uso: executar como subcomando 'list-controls' para descobrir classes de controles
    (toolbars verticais, panels, tabs, etc.) em qualquer tela do UauXT.
    Retorna lista de controles com handle, class_name, text, rect e screen_rect.
    """
    EnumChildProc = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.wintypes.HWND, ctypes.wintypes.LPARAM)

    _app, main_win = _connect_uauxt_window()
    root_hwnd = main_win.handle

    controls: List[Dict[str, Any]] = []
    cf_lower = class_filter.lower()
    tf_lower = text_filter.lower()

    def _enum_cb(hwnd: int, _lparam: int) -> bool:
        cls_buf = ctypes.create_unicode_buffer(256)
        ctypes.windll.user32.GetClassNameW(hwnd, cls_buf, 256)
        cls = cls_buf.value

        txt_buf = ctypes.create_unicode_buffer(512)
        ctypes.windll.user32.GetWindowTextW(hwnd, txt_buf, 512)
        txt = txt_buf.value.strip()

        if cf_lower and cf_lower not in cls.lower():
            return True
        if tf_lower and tf_lower not in txt.lower():
            return True

        rect = ctypes.wintypes.RECT()
        ctypes.windll.user32.GetWindowRect(hwnd, ctypes.byref(rect))
        w = rect.right - rect.left
        h = rect.bottom - rect.top

        is_visible = bool(ctypes.windll.user32.IsWindowVisible(hwnd))
        is_enabled = bool(ctypes.windll.user32.IsWindowEnabled(hwnd))

        automation_id = None
        try:
            app_uia = pywinauto.Application(backend="uia").connect(path="UauXT.exe")
            win_uia = app_uia.top_window()
            for child in win_uia.descendants():
                try:
                    ctrl_handle = int(child.handle)
                except Exception:
                    ctrl_handle = None
                if ctrl_handle != hwnd:
                    continue
                automation_id = _safe(lambda: child.automation_id(), None)
                if automation_id in (None, ""):
                    automation_id = _safe(lambda: child.control_id(), None)
                break
        except Exception:
            automation_id = None

        controls.append({
            "handle": hwnd,
            "class_name": cls,
            "text": txt,
            "automation_id": automation_id,
            "screen_rect": [rect.left, rect.top, rect.right, rect.bottom],
            "size": [w, h],
            "visible": is_visible,
            "enabled": is_enabled,
        })
        return True

    cb = EnumChildProc(_enum_cb)
    ctypes.windll.user32.EnumChildWindows(root_hwnd, cb, 0)

    # Agrupa por class_name para facilitar análise
    by_class: Dict[str, int] = {}
    for c in controls:
        by_class[c["class_name"]] = by_class.get(c["class_name"], 0) + 1

    return {
        "ok": True,
        "total": len(controls),
        "classes_summary": dict(sorted(by_class.items(), key=lambda x: -x[1])),
        "controls": controls,
    }


def list_toolbar_buttons(toolbar_class: str = "msvb_lib_toolbar") -> Dict[str, Any]:
    """Descobre todas as toolbars da janela UauXT e retorna index + rect de cada botao.

    Uso: executar como subcomando 'list-toolbar-buttons' para mapear indices de botoes
    em qualquer tela do UauXT que contenha toolbar da classe msvb_lib_toolbar.
    Retorna lista de toolbars; cada toolbar tem 'buttons' com index, client_rect e screen_center.
    """
    TB_BUTTONCOUNT = 0x418
    TB_GETITEMRECT = 0x41D
    MEM_COMMIT = 0x1000
    MEM_RESERVE = 0x2000
    PAGE_READWRITE = 0x04
    MEM_RELEASE = 0x8000
    PROCESS_ALL_ACCESS = 0x001F0FFF

    EnumChildProc = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.wintypes.HWND, ctypes.wintypes.LPARAM)

    _app, main_win = _connect_uauxt_window()

    toolbar_handles: List[int] = []

    def _enum_cb(hwnd: int, _lparam: int) -> bool:
        buf = ctypes.create_unicode_buffer(256)
        ctypes.windll.user32.GetClassNameW(hwnd, buf, 256)
        if buf.value == toolbar_class:
            toolbar_handles.append(hwnd)
        return True

    ctypes.windll.user32.EnumChildWindows(main_win.handle, EnumChildProc(_enum_cb), 0)

    if not toolbar_handles:
        return {"ok": False, "action": "list-toolbar-buttons", "error": f"Nenhuma toolbar '{toolbar_class}' encontrada."}

    import struct as _struct

    def _get_rect(hwnd: int):
        class WRECT(ctypes.Structure):
            _fields_ = [("left", ctypes.c_long), ("top", ctypes.c_long), ("right", ctypes.c_long), ("bottom", ctypes.c_long)]
        r = WRECT()
        ctypes.windll.user32.GetWindowRect(hwnd, ctypes.byref(r))
        return r.left, r.top, r.right, r.bottom

    toolbars_result = []
    for tb_handle in toolbar_handles:
        tb_l, tb_t, tb_r, tb_b = _get_rect(tb_handle)
        btn_count = ctypes.windll.user32.SendMessageW(tb_handle, TB_BUTTONCOUNT, 0, 0)

        pid = ctypes.wintypes.DWORD()
        ctypes.windll.user32.GetWindowThreadProcessId(tb_handle, ctypes.byref(pid))
        h_proc = ctypes.windll.kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, pid.value)
        remote_rect = ctypes.windll.kernel32.VirtualAllocEx(h_proc, None, 16, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE)

        buttons = []
        for i in range(btn_count):
            ctypes.windll.user32.SendMessageW(tb_handle, TB_GETITEMRECT, i, remote_rect)
            local_rect_b = (ctypes.c_byte * 16)()
            ctypes.windll.kernel32.ReadProcessMemory(h_proc, remote_rect, local_rect_b, 16, None)
            bl, bt, br, bb = _struct.unpack_from("<iiii", bytes(local_rect_b), 0)
            w = br - bl
            buttons.append({
                "index": i,
                "client_rect": [bl, bt, br, bb],
                "screen_center": [tb_l + (bl + br) // 2, tb_t + (bt + bb) // 2],
                "width_px": w,
                "is_separator": w < 15,
            })

        ctypes.windll.kernel32.VirtualFreeEx(h_proc, remote_rect, 0, MEM_RELEASE)
        ctypes.windll.kernel32.CloseHandle(h_proc)

        toolbars_result.append({
            "handle": tb_handle,
            "screen_rect": [tb_l, tb_t, tb_r, tb_b],
            "button_count": btn_count,
            "buttons": buttons,
        })

    return {"ok": True, "action": "list-toolbar-buttons", "toolbar_class": toolbar_class, "toolbars": toolbars_result}


def map_toolbar_buttons(toolbar_class: str = "msvb_lib_toolbar", hover_delay_s: float = 0.9, toolbar_index: int = 0) -> Dict[str, Any]:
    """Mapeia nomes dos botoes da toolbar fazendo hover com o mouse e lendo o tooltip VB6.

    Para cada botao nao-separador:
      1. SetForegroundWindow na janela UauXT
      2. SetCursorPos para o screen_center do botao
      3. Aguarda hover_delay_s para o tooltip aparecer
      4. Enumera todas as janelas top-level e child buscando tooltips visiveis:
           - Classe "msvb_lib_tooltips" (tooltip nativo VB6)
           - Classe "tooltips_class32" (tooltip Windows padrao)
      5. Tenta ler o texto via GetWindowTextW e WM_GETTEXT
      6. Registra index -> nome (ou "?" se nao detectado)

    Util para auto-mapear indices de toolbar em qualquer tela do UauXT.
    """
    TB_BUTTONCOUNT = 0x418
    TB_GETITEMRECT = 0x41D
    MEM_COMMIT  = 0x1000
    MEM_RESERVE = 0x2000
    PAGE_READWRITE = 0x04
    MEM_RELEASE = 0x8000
    PROCESS_ALL_ACCESS = 0x001F0FFF
    WM_GETTEXT       = 0x000D
    WM_GETTEXTLENGTH = 0x000E
    TOOLTIP_CLASSES  = ("msvb_lib_tooltips", "tooltips_class32", "ToolTips_class32")

    EnumChildProc = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.wintypes.HWND, ctypes.wintypes.LPARAM)
    EnumWndProc   = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.wintypes.HWND, ctypes.wintypes.LPARAM)

    _app, main_win = _connect_uauxt_window()

    # --- Localiza toolbars ---
    toolbar_handles: List[int] = []

    def _enum_tb(hwnd: int, _: int) -> bool:
        buf = ctypes.create_unicode_buffer(256)
        ctypes.windll.user32.GetClassNameW(hwnd, buf, 256)
        if buf.value == toolbar_class:
            toolbar_handles.append(hwnd)
        return True

    ctypes.windll.user32.EnumChildWindows(main_win.handle, EnumChildProc(_enum_tb), 0)
    if not toolbar_handles:
        return {"ok": False, "action": "map-toolbar-buttons", "error": f"Nenhuma toolbar '{toolbar_class}' encontrada."}

    import struct as _struct

    def _get_rect(hwnd: int):
        class WRECT(ctypes.Structure):
            _fields_ = [("left", ctypes.c_long), ("top", ctypes.c_long), ("right", ctypes.c_long), ("bottom", ctypes.c_long)]
        r = WRECT()
        ctypes.windll.user32.GetWindowRect(hwnd, ctypes.byref(r))
        return r.left, r.top, r.right, r.bottom

    # Ordena toolbars por area (largura * altura) decrescente: maior = indice 0, etc.
    def _area(hwnd: int) -> int:
        l, t, r, b = _get_rect(hwnd)
        return (r - l) * (b - t)

    toolbar_handles_sorted = sorted(toolbar_handles, key=_area, reverse=True)

    if toolbar_index >= len(toolbar_handles_sorted):
        return {
            "ok": False,
            "action": "map-toolbar-buttons",
            "error": f"toolbar_index={toolbar_index} invalido — apenas {len(toolbar_handles_sorted)} toolbar(s) '{toolbar_class}' encontrada(s).",
            "available_count": len(toolbar_handles_sorted),
        }

    selected_handle = toolbar_handles_sorted[toolbar_index]
    def _read_tooltip_text() -> str:
        candidates: List[int] = []

        def _enum_top(hwnd: int, _: int) -> bool:
            candidates.append(hwnd)
            return True

        ctypes.windll.user32.EnumWindows(EnumWndProc(_enum_top), 0)

        for hwnd in candidates:
            cls_buf = ctypes.create_unicode_buffer(128)
            ctypes.windll.user32.GetClassNameW(hwnd, cls_buf, 128)
            if cls_buf.value not in TOOLTIP_CLASSES:
                continue
            if not ctypes.windll.user32.IsWindowVisible(hwnd):
                continue

            # Metodo 1: GetWindowTextW
            tlen = ctypes.windll.user32.GetWindowTextLengthW(hwnd)
            if tlen > 0:
                tbuf = ctypes.create_unicode_buffer(tlen + 2)
                ctypes.windll.user32.GetWindowTextW(hwnd, tbuf, tlen + 2)
                if tbuf.value.strip():
                    return tbuf.value.strip()

            # Metodo 2: WM_GETTEXTLENGTH + WM_GETTEXT
            wlen = ctypes.windll.user32.SendMessageW(hwnd, WM_GETTEXTLENGTH, 0, 0)
            if wlen > 0:
                wbuf = ctypes.create_unicode_buffer(wlen + 2)
                ctypes.windll.user32.SendMessageW(hwnd, WM_GETTEXT, wlen + 2, wbuf)
                if wbuf.value.strip():
                    return wbuf.value.strip()

            # Metodo 3: varrer janelas filhas da tooltip
            child_hwnds: List[int] = []

            def _enum_child_tt(child_hwnd: int, _: int) -> bool:
                child_hwnds.append(child_hwnd)
                return True

            ctypes.windll.user32.EnumChildWindows(hwnd, EnumChildProc(_enum_child_tt), 0)
            for child in child_hwnds:
                clen = ctypes.windll.user32.GetWindowTextLengthW(child)
                if clen > 0:
                    cbuf = ctypes.create_unicode_buffer(clen + 2)
                    ctypes.windll.user32.GetWindowTextW(child, cbuf, clen + 2)
                    if cbuf.value.strip():
                        return cbuf.value.strip()

        return ""

    tb_handle = selected_handle
    tb_l, tb_t, tb_r, tb_b = _get_rect(tb_handle)
    btn_count = ctypes.windll.user32.SendMessageW(tb_handle, TB_BUTTONCOUNT, 0, 0)

    pid = ctypes.wintypes.DWORD()
    ctypes.windll.user32.GetWindowThreadProcessId(tb_handle, ctypes.byref(pid))
    h_proc = ctypes.windll.kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, pid.value)
    remote_rect = ctypes.windll.kernel32.VirtualAllocEx(h_proc, None, 16, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE)

    ctypes.windll.user32.SetForegroundWindow(main_win.handle)
    time.sleep(0.3)

    mapping = []
    try:
        for i in range(btn_count):
            ctypes.windll.user32.SendMessageW(tb_handle, TB_GETITEMRECT, i, remote_rect)
            local_rect_b = (ctypes.c_byte * 16)()
            ctypes.windll.kernel32.ReadProcessMemory(h_proc, remote_rect, local_rect_b, 16, None)
            bl, bt, br, bb = _struct.unpack_from("<iiii", bytes(local_rect_b), 0)
            w  = br - bl
            cx = tb_l + (bl + br) // 2
            cy = tb_t + (bt + bb) // 2

            if w < 15:
                mapping.append({"index": i, "name": "---SEPARADOR---", "is_separator": True, "screen_center": [cx, cy]})
                continue

            # Hover e leitura do tooltip
            ctypes.windll.user32.SetCursorPos(cx, cy)
            time.sleep(hover_delay_s)
            name = _read_tooltip_text()

            mapping.append({
                "index": i,
                "name": name if name else "?",
                "name_found": bool(name),
                "is_separator": False,
                "screen_center": [cx, cy],
                "width_px": w,
            })
    finally:
        ctypes.windll.kernel32.VirtualFreeEx(h_proc, remote_rect, 0, MEM_RELEASE)
        ctypes.windll.kernel32.CloseHandle(h_proc)

    # Move mouse para fora da toolbar ao terminar
    ctypes.windll.user32.SetCursorPos(tb_l - 50, tb_t)

    mapped_count = sum(1 for b in mapping if not b.get("is_separator") and b.get("name_found"))
    total_buttons = sum(1 for b in mapping if not b.get("is_separator"))

    return {
        "ok": True,
        "action": "map-toolbar-buttons",
        "toolbar_handle": tb_handle,
        "button_count": btn_count,
        "mapped": mapped_count,
        "total_buttons": total_buttons,
        "hover_delay_s": hover_delay_s,
        "mapping": mapping,
    }


def click_toolbar_button(button_index: int, toolbar_class: str = "msvb_lib_toolbar", click_x_pct: float = 0.5) -> Dict[str, Any]:
    """Clica em botao de toolbar VB6 (msvb_lib_toolbar) pelo indice (0-based).

    A toolbar VB6 (msvb_lib_toolbar) nao expoe nomes de botoes via UIA, MSAA ou TB_GETBUTTONTEXTW.
    O mecanismo confiavel e usar TB_GETITEMRECT (wParam=indice) para obter o rect do botao
    e clicar na posicao definida por click_x_pct (0.0=borda esquerda, 0.5=centro, 1.0=borda direita).
    Use 0.5 (padrao) para botoes normais; use ~0.85 para acionar o dropdown/sidebutton de split-buttons.
    Use 'list-toolbar-buttons' para descobrir indices.

    button_index: indice 0-based do botao desejado na toolbar (obrigatorio).
    toolbar_class: classe Win32 da toolbar (default: msvb_lib_toolbar).
    click_x_pct: posicao horizontal relativa no rect do botao (0.0-1.0, default: 0.5 = centro).
    """

    TB_BUTTONCOUNT = 0x418
    TB_GETITEMRECT = 0x41D  # wParam=index_0based, lParam=ptr_to_RECT_em_processo_alvo

    MEM_COMMIT = 0x1000
    MEM_RESERVE = 0x2000
    PAGE_READWRITE = 0x04
    MEM_RELEASE = 0x8000
    PROCESS_ALL_ACCESS = 0x001F0FFF

    EnumChildProc = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.wintypes.HWND, ctypes.wintypes.LPARAM)

    _app, main_win = _connect_uauxt_window()

    toolbar_handles: List[int] = []

    def _enum_cb(hwnd: int, _lparam: int) -> bool:
        buf = ctypes.create_unicode_buffer(256)
        ctypes.windll.user32.GetClassNameW(hwnd, buf, 256)
        if buf.value == toolbar_class:
            toolbar_handles.append(hwnd)
        return True

    ctypes.windll.user32.EnumChildWindows(main_win.handle, EnumChildProc(_enum_cb), 0)

    if not toolbar_handles:
        return {
            "ok": False,
            "action": "click-toolbar-button",
            "error": f"Nenhuma janela da classe '{toolbar_class}' encontrada no processo UauXT.",
        }

    # Preferir toolbar horizontal (width >> height)
    def _get_rect(hwnd: int) -> Tuple[int, int, int, int]:
        class WRECT(ctypes.Structure):
            _fields_ = [("left", ctypes.c_long), ("top", ctypes.c_long), ("right", ctypes.c_long), ("bottom", ctypes.c_long)]
        r = WRECT()
        ctypes.windll.user32.GetWindowRect(hwnd, ctypes.byref(r))
        return r.left, r.top, r.right, r.bottom

    selected_handle = toolbar_handles[0]
    for h in toolbar_handles:
        l, t, r, b = _get_rect(h)
        w, ht = r - l, b - t
        # escolhe a toolbar mais larga (horizontal principal de acoes)
        sl, st, sr, sb = _get_rect(selected_handle)
        if w > (sr - sl):
            selected_handle = h

    tb_handle = selected_handle
    tb_l, tb_t, tb_r, tb_b = _get_rect(tb_handle)

    # Valida indice
    btn_count = ctypes.windll.user32.SendMessageW(tb_handle, TB_BUTTONCOUNT, 0, 0)
    if button_index < 0 or button_index >= btn_count:
        return {
            "ok": False,
            "action": "click-toolbar-button",
            "error": f"button_index={button_index} fora do range [0, {btn_count - 1}] para a toolbar selecionada (handle={tb_handle}).",
            "button_count": btn_count,
        }

    # Abre processo alvo para TB_GETITEMRECT cross-process
    pid = ctypes.wintypes.DWORD()
    ctypes.windll.user32.GetWindowThreadProcessId(tb_handle, ctypes.byref(pid))
    h_proc = ctypes.windll.kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, pid.value)
    if not h_proc:
        return {
            "ok": False,
            "action": "click-toolbar-button",
            "error": f"Nao foi possivel abrir o processo PID={pid.value} para leitura de memoria.",
        }

    import struct as _struct

    remote_rect = ctypes.windll.kernel32.VirtualAllocEx(h_proc, None, 16, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE)
    try:
        ret = ctypes.windll.user32.SendMessageW(tb_handle, TB_GETITEMRECT, button_index, remote_rect)
        if not ret:
            return {
                "ok": False,
                "action": "click-toolbar-button",
                "error": f"TB_GETITEMRECT falhou para indice={button_index}.",
            }

        local_rect_b = (ctypes.c_byte * 16)()
        ctypes.windll.kernel32.ReadProcessMemory(h_proc, remote_rect, local_rect_b, 16, None)
        bl, bt, br, bb = _struct.unpack_from("<iiii", bytes(local_rect_b), 0)

        # Posicao do clique no botao: click_x_pct define a fracao horizontal (0.0=esq, 0.5=centro, 1.0=dir)
        # Para split-buttons com dropdown na borda direita, use click_x_pct~=0.85
        cx_client = bl + int((br - bl) * max(0.0, min(1.0, click_x_pct)))
        cy_client = (bt + bb) // 2
        screen_x = tb_l + cx_client
        screen_y = tb_t + cy_client
    finally:
        ctypes.windll.kernel32.VirtualFreeEx(h_proc, remote_rect, 0, MEM_RELEASE)
        ctypes.windll.kernel32.CloseHandle(h_proc)

    # Clica usando eventos fisicos de mouse (SetCursorPos + mouse_event).
    # click_input do pywinauto nao dispara corretamente em toolbars VB6 (msvb_lib_toolbar).
    MOUSEEVENTF_LEFTDOWN = 0x0002
    MOUSEEVENTF_LEFTUP   = 0x0004
    ctypes.windll.user32.SetForegroundWindow(main_win.handle)
    time.sleep(0.1)
    ctypes.windll.user32.SetCursorPos(screen_x, screen_y)
    time.sleep(0.08)
    ctypes.windll.user32.mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    time.sleep(0.05)
    ctypes.windll.user32.mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
    time.sleep(0.15)

    return {
        "ok": True,
        "action": "click-toolbar-button",
        "button_index": button_index,
        "button_count": btn_count,
        "toolbar_handle": tb_handle,
        "button_rect_client": [bl, bt, br, bb],
        "click_screen": [screen_x, screen_y],
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

    parser_list_ctrl = subparsers.add_parser("list-controls", help="Enumera todos os controles filhos da janela UauXT (discovery de classes)")
    parser_list_ctrl.add_argument("--class-filter", default="", help="Filtrar por substring no nome da classe (case-insensitive)")
    parser_list_ctrl.add_argument("--text-filter", default="", help="Filtrar por substring no texto do controle (case-insensitive)")
    parser_list_ctrl.add_argument("--pretty", action="store_true")

    parser_list_tb = subparsers.add_parser("list-toolbar-buttons", help="Lista todos os botoes de todas as toolbars (discovery de indices)")
    parser_list_tb.add_argument("--toolbar-class", default="msvb_lib_toolbar", help="Classe da janela toolbar (default: msvb_lib_toolbar)")
    parser_list_tb.add_argument("--pretty", action="store_true")

    parser_map_tb = subparsers.add_parser("map-toolbar-buttons", help="Faz hover em cada botao e captura o nome via tooltip (auto-mapeamento)")
    parser_map_tb.add_argument("--toolbar-class", default="msvb_lib_toolbar", help="Classe da janela toolbar (default: msvb_lib_toolbar)")
    parser_map_tb.add_argument("--toolbar-index", type=int, default=0, help="Indice da toolbar ordenada por area desc (0=maior/horizontal, 1=vertical, etc.)")
    parser_map_tb.add_argument("--hover-delay", type=float, default=0.9, help="Segundos de espera por tooltip apos hover (default: 0.9)")
    parser_map_tb.add_argument("--pretty", action="store_true")

    parser_toolbar = subparsers.add_parser("click-toolbar-button", help="Clica em botao de toolbar VB6 (msvb_lib_toolbar) pelo indice (TB_GETITEMRECT)")
    parser_toolbar.add_argument("--button-index", type=int, required=True, help="Indice 0-based do botao na toolbar")
    parser_toolbar.add_argument("--toolbar-class", default="msvb_lib_toolbar", help="Classe da janela toolbar (default: msvb_lib_toolbar)")
    parser_toolbar.add_argument("--click-x-pct", type=float, default=0.5, help="Fracao horizontal do rect do botao para o clique (0.0=esq, 0.5=centro, 1.0=dir). Use ~0.85 para dropdown/sidebutton. (default: 0.5)")
    parser_toolbar.add_argument("--pretty", action="store_true")

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

        if args.command == "list-controls":
            data = list_controls(class_filter=args.class_filter, text_filter=args.text_filter)
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        if args.command == "list-toolbar-buttons":
            data = list_toolbar_buttons(toolbar_class=args.toolbar_class)
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        if args.command == "map-toolbar-buttons":
            data = map_toolbar_buttons(toolbar_class=args.toolbar_class, hover_delay_s=float(args.hover_delay), toolbar_index=int(args.toolbar_index))
            _emit(data, pretty=args.pretty)
            return 0 if data.get("ok") else 1

        if args.command == "click-toolbar-button":
            data = click_toolbar_button(
                button_index=int(args.button_index),
                toolbar_class=args.toolbar_class,
                click_x_pct=float(args.click_x_pct),
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
