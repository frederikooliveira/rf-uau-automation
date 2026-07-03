from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "resources" / "scripts"))

import uauxt_probe


class FakeControl:
    def __init__(self, handle, class_name, window_text, automation_id, visible=True, enabled=True):
        self._handle = handle
        self._class_name = class_name
        self._window_text = window_text
        self._automation_id = automation_id
        self._visible = visible
        self._enabled = enabled

    @property
    def handle(self):
        return self._handle

    def class_name(self):
        return self._class_name

    def window_text(self):
        return self._window_text

    def automation_id(self):
        return self._automation_id

    def is_visible(self):
        return self._visible

    def is_enabled(self):
        return self._enabled


def test_collect_control_identity_returns_automation_id():
    ctrl = FakeControl(handle=10423244, class_name="ThunderRT6CommandButton", window_text="Inserir", automation_id="5")

    result = uauxt_probe._collect_control_identity(ctrl)

    assert result["handle"] == 10423244
    assert result["class_name"] == "ThunderRT6CommandButton"
    assert result["text"] == "Inserir"
    assert result["automation_id"] == "5"
    assert result["visible"] is True
    assert result["enabled"] is True
