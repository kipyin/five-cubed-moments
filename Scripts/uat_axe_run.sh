#!/usr/bin/env bash
# Local UAT capture driver: build + install GraceNotes (Demo), then run axe batches + screenshots.
# No GitHub Actions. Prerequisite: `brew install axe`, Xcode + Simulator.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROJECT="${PROJECT:-GraceNotes/GraceNotes.xcodeproj}"
DEMO_SCHEME="${DEMO_SCHEME:-GraceNotes (Demo)}"
CONFIGURATION="${UAT_CONFIGURATION:-Demo}"
BUNDLE_ID="${RUN_BUNDLE_ID:-com.gracenotes.GraceNotes}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro,OS=latest}"
DERIVED_DATA="${UAT_AXE_DERIVED_DATA:-/tmp/GraceNotes-UATAxeDerivedData}"
PYTHON="${PYTHON:-python3}"
SIM_HELPER="${ROOT}/Scripts/simulator_destination.py"
BATCH_FLAGS=(--wait-timeout 25 --poll-interval 0.3)

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

echo "UAT axe: building ${DEMO_SCHEME} (${CONFIGURATION})…"
xcodebuild \
  -project "${PROJECT}" \
  -scheme "${DEMO_SCHEME}" \
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
xcrun simctl terminate "${udid}" "${BUNDLE_ID}" >/dev/null 2>&1 || true
xcrun simctl launch "${udid}" "${BUNDLE_ID}" >/dev/null

stamp="$(date +%Y%m%d-%H%M%S)"
out_dir="${ROOT}/build/uat-captures/${stamp}"
mkdir -p "${out_dir}"

echo "UAT axe: captures -> ${out_dir}"
echo "NOTE: If this is a fresh simulator, complete onboarding once so Today/Past/Settings tabs exist."

run_batch() {
  local file="$1"
  echo "  batch ${file}"
  axe batch --udid "${udid}" "${BATCH_FLAGS[@]}" --file "${ROOT}/${file}"
}

snap() {
  local path="$1"
  axe screenshot --udid "${udid}" --output "${path}"
}

run_batch "Scripts/axe/batch/01_today_after_launch.txt"
snap "${out_dir}/01_today.png"

run_batch "Scripts/axe/batch/02_navigate_past.txt"
snap "${out_dir}/02_past.png"

run_batch "Scripts/axe/batch/03_navigate_settings.txt"
snap "${out_dir}/03_settings.png"

run_batch "Scripts/axe/batch/04_return_today.txt"
snap "${out_dir}/04_today_return.png"

echo "Done. Review PNGs in: ${out_dir}"
echo "Optional: axe record-video --udid ${udid} ... for MP4 (see docs/uat-scenarios.md)."
