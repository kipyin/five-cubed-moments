"""Rich-based TUI for ``grace sentry start`` (status strip + log tail)."""

from __future__ import annotations

from collections import deque
from typing import Final

from rich import box
from rich.console import Group
from rich.live import Live
from rich.panel import Panel
from rich.table import Table
from rich.text import Text

_LOG_MAX_LINES: Final = 200
_LOG_VISIBLE: Final = 40


class RichSentryTUI:
    """Pin step / branch / PR / file at top; scrollable log tail at bottom."""

    def __init__(self) -> None:
        self._step = "—"
        self._branch = "—"
        self._pr = "—"
        self._target_file = "—"
        self._lines: deque[str] = deque(maxlen=_LOG_MAX_LINES)
        self._live: Live | None = None

    def __enter__(self) -> RichSentryTUI:
        self._live = Live(
            self._render(),
            refresh_per_second=8,
            transient=False,
            vertical_overflow="visible",
        )
        self._live.__enter__()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        if self._live is not None:
            self._live.__exit__(exc_type, exc_val, exc_tb)
            self._live = None

    def set_step(self, step: str) -> None:
        self._step = step
        self._refresh()

    def set_branch(self, branch: str | None) -> None:
        self._branch = branch or "—"
        self._refresh()

    def set_pr(self, pr: str | None) -> None:
        self._pr = pr or "—"
        self._refresh()

    def set_target_file(self, path: str | None) -> None:
        self._target_file = path or "—"
        self._refresh()

    def log(self, line: str) -> None:
        self._lines.append(line)
        self._refresh()

    def _refresh(self) -> None:
        if self._live is not None:
            self._live.update(self._render())

    def _render(self) -> Group:
        status = Table(show_header=False, box=box.SIMPLE, padding=(0, 1))
        status.add_column("Label", style="bold cyan", no_wrap=True)
        status.add_column("Value", overflow="fold")
        status.add_row("Step", self._step)
        status.add_row("Branch", self._branch)
        status.add_row("PR", self._pr)
        status.add_row("File", self._target_file)

        tail = list(self._lines)[-_LOG_VISIBLE:]
        log_text = Text("\n".join(tail) if tail else "(no events yet)")
        top = Panel(status, title="grace sentry", border_style="blue")
        bottom = Panel(log_text, title="Log", border_style="dim", height=min(_LOG_VISIBLE + 4, 48))
        return Group(top, bottom)
