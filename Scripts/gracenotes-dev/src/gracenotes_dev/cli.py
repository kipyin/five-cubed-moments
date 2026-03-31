"""Typer entrypoint for the ``grace`` console script."""

from __future__ import annotations

import json
import subprocess
import sys
from typing import Annotated

import typer
from rich.console import Console

from gracenotes_dev import xcode as xcode_helpers
from gracenotes_dev import simulator

app = typer.Typer(
    no_args_is_help=True,
    rich_markup_mode="rich",
    help="Grace Notes developer CLI — simulators, builds, tests, CI.",
)
sim_app = typer.Typer(help="Simulator destination helpers (xcrun simctl).")
app.add_typer(sim_app, name="sim")

_console = Console(stderr=True)


def _stdout_console() -> Console:
    return Console(file=sys.stdout, force_terminal=sys.stdout.isatty())


@sim_app.command("list")
def sim_list(
    json_out: Annotated[
        bool,
        typer.Option("--json", help="Emit a JSON array of xcodebuild destination strings."),
    ] = False,
) -> None:
    """List installed iOS Simulator destinations (short ``platform=…`` lines)."""
    rows = simulator.load_available_ios_devices()
    lines: list[str] = []
    seen: set[tuple[str, str]] = set()
    for row in sorted(rows, key=lambda item: (item["name"], simulator.version_tuple(item["runtime_version"]))):
        key = (row["name"], row["runtime_version"])
        if key in seen:
            continue
        seen.add(key)
        lines.append(f"platform=iOS Simulator,name={row['name']},OS={row['runtime_version']}")
    if json_out:
        json.dump(lines, sys.stdout, indent=2)
        sys.stdout.write("\n")
        return
    out = _stdout_console()
    for line in lines:
        out.print(line)


@sim_app.command("resolve")
def sim_resolve(
    spec: Annotated[str, typer.Argument(help="Device@os shortcut or full platform=… destination.")],
    json_out: Annotated[
        bool,
        typer.Option("--json", help="Emit JSON {\"resolved\": \"…\"}."),
    ] = False,
) -> None:
    """Resolve ``@latest`` (or validate a full destination) for xcodebuild."""
    rows = simulator.load_available_ios_devices()
    if spec.startswith("platform="):
        resolved = simulator.resolve_destination(spec, rows)
    elif "@" in spec:
        name, os_value = spec.rsplit("@", 1)
        destination = f"platform=iOS Simulator,name={name.strip()},OS={os_value.strip()}"
        resolved = simulator.resolve_destination(destination, rows)
    else:
        _console.print(
            "[red]Expected device@os (e.g. iPhone 17 Pro@latest) or a full platform=… string.[/red]"
        )
        raise typer.Exit(code=2)
    if json_out:
        json.dump({"resolved": resolved}, sys.stdout, indent=2)
        sys.stdout.write("\n")
        return
    _stdout_console().print(resolved)


@sim_app.command("reset")
def sim_reset() -> None:
    """Shutdown and erase all simulators (``simctl shutdown all`` then ``erase all``)."""
    shutdown, erase = xcode_helpers.simctl_reset_all_argv()
    subprocess.run(shutdown, check=False)
    subprocess.run(erase, check=False)
