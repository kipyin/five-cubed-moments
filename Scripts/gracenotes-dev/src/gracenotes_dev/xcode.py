"""xcodebuild-related helpers (logic migrated from the root Makefile)."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Sequence

from gracenotes_dev import config
from gracenotes_dev.simulator import destination_display_name


def repo_root_from(start: Path | None = None) -> Path:
    """Walk up from ``start`` to find the repo root (directory containing GraceNotes/)."""
    here = (start or Path.cwd()).resolve()
    for candidate in [here, *here.parents]:
        project = candidate / config.DEFAULT_PROJECT_RELATIVE
        if (candidate / "GraceNotes").is_dir() and project.exists():
            return candidate
    # Fall back to cwd for relative paths (callers may set cwd explicitly).
    return here


def ios_major_from_resolved_destination(resolved_destination: str) -> int | None:
    """Parse major iOS version from ``OS=`` in an xcodebuild destination string."""
    match = re.search(r"(?:^|,)OS=([^,]+)", resolved_destination)
    if not match:
        return None
    value = match.group(1).strip()
    if value == "latest":
        return None
    major_str = value.split(".", 1)[0]
    if not major_str.isdigit():
        return None
    return int(major_str)


def legacy_skip_flags_if_needed(resolved_destination: str) -> list[str]:
    """Return Makefile-equivalent skip flags when the runtime major version is under 18."""
    major = ios_major_from_resolved_destination(resolved_destination)
    if major is None:
        return []
    if major < 18:
        return list(config.LEGACY_RUNTIME_SKIP_FLAGS)
    return []


def xcodebuild_test_flag_list() -> list[str]:
    """Parallel test flag tuple as a list for subprocess."""
    return list(config.XCODE_TEST_FLAGS)


def xcodebuild_base_args(
    *,
    project: str | Path,
    scheme: str,
    resolved_destination: str,
) -> list[str]:
    """Shared argv prefix: ``xcodebuild -project … -scheme … -destination …``."""
    return [
        "xcodebuild",
        "-project",
        str(project),
        "-scheme",
        scheme,
        "-destination",
        resolved_destination,
    ]


def build_argv(
    *,
    project: Path,
    scheme: str,
    resolved_destination: str,
    configuration: str | None = None,
    derived_data_path: Path | str | None = None,
) -> list[str]:
    """``xcodebuild build`` argument list."""
    args = xcodebuild_base_args(project=project, scheme=scheme, resolved_destination=resolved_destination)
    if configuration:
        args.extend(["-configuration", configuration])
    if derived_data_path is not None:
        args.extend(["-derivedDataPath", str(derived_data_path)])
    args.append("build")
    return args


def test_argv(
    *,
    project: Path,
    scheme: str,
    resolved_destination: str,
    only_testing: Sequence[str] | None = None,
    extra_xcodebuild_args: Sequence[str] | None = None,
    isolated_derived_data: Path | str | None = None,
    apply_legacy_skips: bool = True,
    xcode_test_flags: Sequence[str] | None = None,
    legacy_skip_flags: Sequence[str] | None = None,
) -> list[str]:
    """``xcodebuild test`` argument list matching Makefile ``test`` / ``test-unit`` / ``test-ui`` patterns."""
    args = xcodebuild_base_args(project=project, scheme=scheme, resolved_destination=resolved_destination)
    args.extend(list(xcode_test_flags) if xcode_test_flags is not None else xcodebuild_test_flag_list())
    if apply_legacy_skips:
        if legacy_skip_flags is None:
            args.extend(legacy_skip_flags_if_needed(resolved_destination))
        else:
            major = ios_major_from_resolved_destination(resolved_destination)
            if major is not None and major < 18:
                args.extend(list(legacy_skip_flags))
    if isolated_derived_data is not None:
        args.extend(["-derivedDataPath", str(isolated_derived_data)])
    if only_testing:
        for item in only_testing:
            args.extend(["-only-testing", item])
    if extra_xcodebuild_args:
        args.extend(extra_xcodebuild_args)
    args.append("test")
    return args


def simctl_boot_sequence_argv(simulator_name: str) -> tuple[list[str], list[str]]:
    """Return ``simctl boot`` and ``simctl bootstatus -b`` argv lists (smoke / Makefile parity)."""
    boot = ["xcrun", "simctl", "boot", simulator_name]
    bootstatus = ["xcrun", "simctl", "bootstatus", simulator_name, "-b"]
    return boot, bootstatus


def simctl_reset_all_argv() -> tuple[list[str], list[str]]:
    """Return ``simctl shutdown all`` and ``simctl erase all`` argv lists."""
    shutdown = ["xcrun", "simctl", "shutdown", "all"]
    erase = ["xcrun", "simctl", "erase", "all"]
    return shutdown, erase


def resolved_name_for_smoke(resolved_destination: str) -> str:
    """Device name for simctl commands (Makefile ``test-ui-smoke``)."""
    return destination_display_name(resolved_destination)


def built_app_path(derived_data_path: Path, *, scheme: str, configuration: str = "Debug") -> Path:
    """Locate the built ``.app`` bundle under DerivedData products."""
    app_path = (
        derived_data_path
        / "Build"
        / "Products"
        / f"{configuration}-iphonesimulator"
        / f"{scheme}.app"
    )
    if app_path.is_dir():
        return app_path

    matches = sorted(derived_data_path.glob(f"**/{scheme}.app"))
    if matches:
        return matches[0]
    raise FileNotFoundError(f"Could not find {scheme}.app under {derived_data_path}")


def simctl_install_argv(*, app_path: Path, device: str = "booted") -> list[str]:
    """Return ``simctl install`` argv."""
    return ["xcrun", "simctl", "install", device, str(app_path)]


def simctl_launch_argv(*, bundle_id: str, app_args: Sequence[str], device: str = "booted") -> list[str]:
    """Return ``simctl launch`` argv with optional app arguments."""
    return ["xcrun", "simctl", "launch", device, bundle_id, *app_args]
