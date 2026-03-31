"""Greenfield command surface tests for the grace CLI."""

from __future__ import annotations

import io
import os
import unittest
from unittest import mock

from rich.console import Console
from typer.testing import CliRunner

from gracenotes_dev import cli
from gracenotes_dev.cli import app


class CLISurfaceTest(unittest.TestCase):
    def test_root_help_includes_greenfield_commands(self) -> None:
        runner = CliRunner()
        result = runner.invoke(app, ["--help"])

        self.assertEqual(result.exit_code, 0)
        for token in ["doctor", "lint", "sim", "build", "test", "ci", "run"]:
            self.assertIn(token, result.output)
        self.assertIn("Examples:", result.output)
        self.assertIn("grace doctor", result.output)

    def test_sim_help_includes_required_subcommands(self) -> None:
        runner = CliRunner()
        result = runner.invoke(app, ["sim", "--help"])

        self.assertEqual(result.exit_code, 0)
        for token in ["list", "resolve", "reset"]:
            self.assertIn(token, result.output)

    def test_run_help_includes_examples(self) -> None:
        runner = CliRunner()
        result = runner.invoke(app, ["run", "--help"])

        self.assertEqual(result.exit_code, 0)
        self.assertIn("Examples:", result.output)
        self.assertIn("grace run --destination", result.output)

    def test_invalid_kind_uses_designed_error_shape(self) -> None:
        runner = CliRunner()
        result = runner.invoke(app, ["test", "--kind", "invalid"])

        self.assertEqual(result.exit_code, 2)

    def test_unknown_ci_profile_uses_designed_error_shape(self) -> None:
        runner = CliRunner()
        result = runner.invoke(app, ["ci", "--profile", "missing-profile"])

        self.assertEqual(result.exit_code, 2)

    def test_no_color_disables_rich_output(self) -> None:
        stream = io.StringIO()
        stream.isatty = lambda: True  # type: ignore[method-assign]
        with mock.patch.dict(os.environ, {"NO_COLOR": "1"}, clear=False):
            self.assertFalse(cli._supports_rich_output(stream))

    def test_print_error_block_plain_mode(self) -> None:
        buffer = io.StringIO()
        fake_console = Console(file=buffer, force_terminal=False, no_color=True)
        with mock.patch.object(cli, "_stderr_console", fake_console):
            with mock.patch.object(cli, "_supports_rich_output", return_value=False):
                cli._print_error_block(
                    title="Sample Error",
                    problem="Something failed.",
                    likely_cause="Reason here.",
                    try_commands=("grace doctor",),
                    retry_command="grace test --kind all",
                )

        output = buffer.getvalue()
        self.assertIn("Sample Error", output)
        self.assertIn("Problem: Something failed.", output)
        self.assertIn("Likely cause: Reason here.", output)
        self.assertIn("Copy this retry: grace test --kind all", output)
