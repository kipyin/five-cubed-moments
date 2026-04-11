"""Local Cursor ``agent`` CLI integration (no HTTP API)."""

from __future__ import annotations

import shlex
import shutil
import subprocess
from pathlib import Path

from gracenotes_dev.sentry.llm_client import (
    MACOS_XCODE_PREAMBLE,
    build_fix_user_prompt,
    parse_fix_response,
)


def _split_args(raw: str) -> tuple[str, ...]:
    s = raw.strip()
    if not s:
        return ()
    return tuple(shlex.split(s))


def resolve_agent_path(agent_bin: str) -> str:
    """Return path to agent executable, or raise FileNotFoundError."""
    p = Path(agent_bin).expanduser()
    if p.is_file():
        return str(p.resolve())
    found = shutil.which(agent_bin)
    if not found:
        raise FileNotFoundError(
            f"Executable not found on PATH: {agent_bin!r}. "
            "Install Cursor CLI or set SENTRY_AGENT_BIN."
        )
    return found


def propose_swift_fix_via_agent(
    *,
    repo_root: Path,
    agent_bin: str,
    prefix_args: tuple[str, ...],
    extra_args: tuple[str, ...],
    relative_path: str,
    file_content: str,
    timeout_sec: int,
) -> str:
    """
    Run ``agent`` (or ``cursor agent``, etc.) with a single prompt; parse Swift block or NO_CHANGE.

    Default argv shape: ``agent <prefix...> <extra...> "<prompt>"`` (prompt is last).
    """
    resolved = resolve_agent_path(agent_bin)
    body = build_fix_user_prompt(relative_path, file_content)
    prompt = f"{MACOS_XCODE_PREAMBLE}\n\n{body}"
    argv = [resolved, *prefix_args, *extra_args, prompt]
    try:
        proc = subprocess.run(
            argv,
            cwd=repo_root,
            capture_output=True,
            text=True,
            timeout=timeout_sec,
        )
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError(f"agent command timed out after {timeout_sec}s") from exc

    combined = (proc.stdout or "") + "\n" + (proc.stderr or "")
    try:
        return parse_fix_response(combined)
    except RuntimeError as exc:
        raise RuntimeError(
            f"{exc} Exit {proc.returncode}. Output (truncated): {combined[:2000]!r}"
        ) from exc
