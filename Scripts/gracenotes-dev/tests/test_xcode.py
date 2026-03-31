"""Unit tests for xcodebuild helper logic (no xcodebuild)."""

from __future__ import annotations

import unittest
from pathlib import Path

from gracenotes_dev import xcode


class XcodeHelpersTest(unittest.TestCase):
    def test_ios_major_from_destination(self) -> None:
        self.assertEqual(
            xcode.ios_major_from_resolved_destination(
                "platform=iOS Simulator,name=iPhone SE (3rd generation),OS=18.5",
            ),
            18,
        )
        self.assertIsNone(
            xcode.ios_major_from_resolved_destination(
                "platform=iOS Simulator,name=iPhone 17 Pro,OS=latest",
            ),
        )

    def test_legacy_skips_under_ios_18(self) -> None:
        flags = xcode.legacy_skip_flags_if_needed(
            "platform=iOS Simulator,name=iPhone SE (3rd generation),OS=17.5",
        )
        self.assertTrue(all(f.startswith("-skip-testing:") for f in flags))
        self.assertEqual(xcode.legacy_skip_flags_if_needed(
            "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0",
        ), [])

    def test_build_argv_order(self) -> None:
        argv = xcode.build_argv(
            project=Path("GraceNotes/GraceNotes.xcodeproj"),
            scheme="GraceNotes",
            resolved_destination="platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0",
            configuration="Debug",
            derived_data_path="/tmp/dd",
        )
        self.assertEqual(argv[0], "xcodebuild")
        self.assertIn("-project", argv)
        self.assertEqual(argv[-1], "build")
        self.assertIn("-configuration", argv)
        self.assertIn("Debug", argv)
        self.assertIn("-derivedDataPath", argv)
        self.assertIn("/tmp/dd", argv)

    def test_repo_root_from_package_dir(self) -> None:
        repo_root = Path(__file__).resolve().parents[3]
        package_dir = Path(__file__).resolve().parents[1]
        self.assertTrue((repo_root / "GraceNotes").is_dir())
        self.assertEqual(xcode.repo_root_from(package_dir), repo_root)
