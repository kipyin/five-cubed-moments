#!/usr/bin/env bash
# Local UAT capture driver: build + install GraceNotes (UAT), then run axe batches + screenshots.
# Single source of truth for scenarios, batches, MP4 policy, and launch args: Scripts/axe/README.md
# Launch arguments match `GraceNotes/GraceNotes/Application/ProcessInfo+GraceNotesUITesting.swift`.
# No GitHub Actions. Prerequisite: `brew install axe`, Xcode + Simulator.
#
# MP4 (supplemental): By default, records simulator video for UAT-07, UAT-09, UAT-10, UAT-12
# during batch + PNG for that phase. Override:
#   UAT_AXE_MP4=0|no|off     — skip all MP4
#   UAT_AXE_MP4=all         — record every phase (debug)
#   UAT_AXE_MP4=07,12       — comma-separated phase ids (two digits)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROJECT="${PROJECT:-GraceNotes/GraceNotes.xcodeproj}"
UAT_SCHEME="${UAT_SCHEME:-GraceNotes (UAT)}"
CONFIGURATION="${UAT_CONFIGURATION:-UAT}"
BUNDLE_ID="${RUN_BUNDLE_ID:-com.gracenotes.GraceNotes}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro,OS=latest}"
DERIVED_DATA="${UAT_AXE_DERIVED_DATA:-/tmp/GraceNotes-UATAxeDerivedData}"
PYTHON="${PYTHON:-python3}"
SIM_HELPER="${ROOT}/Scripts/simulator_destination.py"
BATCH_FLAGS=(--wait-timeout 25 --poll-interval 0.3)
UAT_AXE_MP4="${UAT_AXE_MP4:-default}"

# Matches `XCUIApplication.configureGraceNotesUITestLaunch` / UI smoke tests.
UITEST_ARGS=(
  -ui-testing
  -grace-notes-uitest-short-autosave
  -AppleLanguages
  '(en)'
  -AppleLocale
  en_US
  -grace-notes-reset-uitest-store
)

# Plain UAT launches (seeded Uat.store): English labels for batch `--label` taps, tab bar reachable (skip welcome + auto post-Seed overlay on 1/1/1 seed data).
UAT_PLAIN_TAB_ARGS=(
  -AppleLanguages
  '(en)'
  -AppleLocale
  en_US
  -grace-notes-uat-fast-onboarding
  -grace-notes-uat-mark-post-seed-journey-seen
)

if ! command -v axe >/dev/null 2>&1; then
  echo "ERROR: axe is not on PATH. Install with: brew install axe" >&2
  exit 1
fi

resolved="$("${PYTHON}" "${SIM_HELPER}" resolve "${DESTINATION}")" || exit $?
udid="$("${PYTHON}" "${SIM_HELPER}" udid "${DESTINATION}")" || exit $?

echo "UAT axe: destination=${resolved}"
echo "UAT axe: udid=${udid}"

xcrun simctl boot "${udid}" >/dev/null 2>&1 || true
xcrun simctl bootstatus "${udid}" -b >/dev/null 2>&1 || true
open -a Simulator 2>/dev/null || true

echo "UAT axe: building ${UAT_SCHEME} (${CONFIGURATION})…"
xcodebuild \
  -project "${PROJECT}" \
  -scheme "${UAT_SCHEME}" \
  -destination "${resolved}" \
  -configuration "${CONFIGURATION}" \
  -derivedDataPath "${DERIVED_DATA}" \
  build

app_path="${DERIVED_DATA}/Build/Products/${CONFIGURATION}-iphonesimulator/GraceNotes.app"
if [[ ! -d "${app_path}" ]]; then
  echo "ERROR: Expected app at ${app_path}" >&2
  exit 1
fi

xcrun simctl install "${udid}" "${app_path}"

stamp="$(date +%Y%m%d-%H%M%S)"
out_dir="${ROOT}/build/uat-captures/${stamp}"
mkdir -p "${out_dir}"

echo "UAT axe: captures -> ${out_dir}"
echo "UAT axe: MP4 mode: ${UAT_AXE_MP4} (set UAT_AXE_MP4=0 to skip motion captures)"
echo "NOTE: Plain UAT phases pass en_US + UAT skip flags so tabs match batches (see Scripts/axe/README.md)."

mp4_rec_pid=""

terminate_app() {
  xcrun simctl terminate "${udid}" "${BUNDLE_ID}" >/dev/null 2>&1 || true
}

# shellcheck disable=SC2120
launch_app() {
  if [[ $# -eq 0 ]]; then
    xcrun simctl launch "${udid}" "${BUNDLE_ID}" >/dev/null
  else
    xcrun simctl launch "${udid}" "${BUNDLE_ID}" "$@" >/dev/null
  fi
  sleep 2
}

run_batch() {
  local file="$1"
  echo "  batch ${file}"
  axe batch --udid "${udid}" "${BATCH_FLAGS[@]}" --file "${ROOT}/${file}"
}

snap() {
  local path="$1"
  axe screenshot --udid "${udid}" --output "${path}"
}

wants_mp4_for_phase() {
  local phase="$1"
  case "${UAT_AXE_MP4}" in
    0 | no | off | false)
      return 1
      ;;
    all | yes | true)
      return 0
      ;;
    default)
      case "$phase" in
        07 | 09 | 10 | 12) return 0 ;;
        *) return 1 ;;
      esac
      ;;
    *)
      [[ ",${UAT_AXE_MP4}," == *",${phase},"* ]]
      ;;
  esac
}

start_phase_mp4_if_needed() {
  local phase="$1"
  local out_mp4="$2"
  mp4_rec_pid=""
  if wants_mp4_for_phase "${phase}"; then
    echo "  record-video -> ${out_mp4}"
    axe record-video --udid "${udid}" --output "${out_mp4}" --fps 10 --quality 75 &
    mp4_rec_pid=$!
    sleep 0.8
  fi
}

stop_phase_mp4_if_needed() {
  if [[ -z "${mp4_rec_pid}" ]]; then
    return 0
  fi
  if kill -0 "${mp4_rec_pid}" 2>/dev/null; then
    kill -INT "${mp4_rec_pid}" 2>/dev/null || true
    wait "${mp4_rec_pid}" 2>/dev/null || true
  fi
  mp4_rec_pid=""
}

trap stop_phase_mp4_if_needed EXIT

# --- UAT-01..04: plain UAT build (seeded Uat.store) ---
terminate_app
launch_app "${UAT_PLAIN_TAB_ARGS[@]}"
run_batch "Scripts/axe/batch/01_today_after_launch.txt"
snap "${out_dir}/01_today.png"

run_batch "Scripts/axe/batch/02_navigate_past.txt"
snap "${out_dir}/02_past.png"

run_batch "Scripts/axe/batch/03_navigate_settings.txt"
snap "${out_dir}/03_settings.png"

run_batch "Scripts/axe/batch/04_return_today.txt"
snap "${out_dir}/04_today_return.png"

# --- UAT-05: UI-test store + smoke parity ---
terminate_app
launch_app "${UITEST_ARGS[@]}"
start_phase_mp4_if_needed "05" "${out_dir}/05_uitest_smoke.mp4"
run_batch "Scripts/axe/batch/05_uitest_smoke_share.txt"
snap "${out_dir}/05_uitest_smoke.png"
stop_phase_mp4_if_needed

# --- UAT-06: persistence on Uat.store (type once, terminate, relaunch, screenshot) ---
terminate_app
launch_app "${UAT_PLAIN_TAB_ARGS[@]}"
start_phase_mp4_if_needed "06" "${out_dir}/06_persistence.mp4"
run_batch "Scripts/axe/batch/06_persistence_gratitude.txt"
terminate_app
launch_app "${UAT_PLAIN_TAB_ARGS[@]}"
sleep 3
snap "${out_dir}/06_persistence.png"
stop_phase_mp4_if_needed

# --- UAT-07: wide review rhythm (UI-test seed) ---
terminate_app
launch_app "${UITEST_ARGS[@]}" -grace-notes-uitest-wide-review-rhythm
start_phase_mp4_if_needed "07" "${out_dir}/07_wide_rhythm.mp4"
run_batch "Scripts/axe/batch/07_review_wide_rhythm.txt"
snap "${out_dir}/07_wide_rhythm.png"
stop_phase_mp4_if_needed

# --- UAT-08 seeded Past ---
terminate_app
launch_app "${UAT_PLAIN_TAB_ARGS[@]}"
start_phase_mp4_if_needed "08" "${out_dir}/08_past_seed.mp4"
run_batch "Scripts/axe/batch/08_past_recurring_cards.txt"
snap "${out_dir}/08_past_seed.png"
stop_phase_mp4_if_needed

# --- UAT-10: post-seed journey (launch flag; UAT-09 fresh-install runs last below) ---
terminate_app
launch_app "${UAT_PLAIN_TAB_ARGS[@]}" -grace-notes-uat-post-seed
start_phase_mp4_if_needed "10" "${out_dir}/10_post_seed.mp4"
run_batch "Scripts/axe/batch/10_post_seed_journey.txt"
snap "${out_dir}/10_post_seed.png"
stop_phase_mp4_if_needed

# --- UAT-11: structured journal (UI-test) ---
terminate_app
launch_app "${UITEST_ARGS[@]}"
start_phase_mp4_if_needed "11" "${out_dir}/11_structured_journal.mp4"
run_batch "Scripts/axe/batch/11_structured_journal_chips.txt"
snap "${out_dir}/11_structured_journal.png"
stop_phase_mp4_if_needed

# --- UAT-12: Share sheet ---
terminate_app
launch_app "${UAT_PLAIN_TAB_ARGS[@]}"
start_phase_mp4_if_needed "12" "${out_dir}/12_share.mp4"
run_batch "Scripts/axe/batch/12_share_sheet.txt"
snap "${out_dir}/12_share.png"
stop_phase_mp4_if_needed

# --- UAT-13: Import / export ---
terminate_app
launch_app "${UAT_PLAIN_TAB_ARGS[@]}"
start_phase_mp4_if_needed "13" "${out_dir}/13_import_export.mp4"
run_batch "Scripts/axe/batch/13_import_export_settings.txt"
snap "${out_dir}/13_import_export.png"
stop_phase_mp4_if_needed

# --- UAT-14: Reminders ---
terminate_app
launch_app "${UAT_PLAIN_TAB_ARGS[@]}"
start_phase_mp4_if_needed "14" "${out_dir}/14_reminders.mp4"
run_batch "Scripts/axe/batch/14_reminders_settings.txt"
snap "${out_dir}/14_reminders.png"
stop_phase_mp4_if_needed

# --- UAT-15: Appearance / Bloom (unlock flag) ---
terminate_app
launch_app "${UAT_PLAIN_TAB_ARGS[@]}" -grace-notes-uat-unlock-summer-toggle
start_phase_mp4_if_needed "15" "${out_dir}/15_appearance.mp4"
run_batch "Scripts/axe/batch/15_appearance_bloom_toggle.txt"
snap "${out_dir}/15_appearance.png"
stop_phase_mp4_if_needed

# --- UAT-09: fresh install (uninstall, reinstall, fast-onboarding arg) ---
terminate_app
xcrun simctl uninstall "${udid}" "${BUNDLE_ID}" >/dev/null 2>&1 || true
xcrun simctl install "${udid}" "${app_path}"
launch_app "${UAT_PLAIN_TAB_ARGS[@]}"
start_phase_mp4_if_needed "09" "${out_dir}/09_fresh_install.mp4"
run_batch "Scripts/axe/batch/09_fresh_install_today.txt"
snap "${out_dir}/09_fresh_install.png"
stop_phase_mp4_if_needed

terminate_app
xcrun simctl install "${udid}" "${app_path}"
echo "UAT axe: reinstalled app after UAT-09 so the next manual make run-uat is not missing the build."

echo "Done. Review PNGs (and any MP4s) in: ${out_dir}"
echo "Docs (SSOT): Scripts/axe/README.md"
