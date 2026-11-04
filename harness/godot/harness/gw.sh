#!/usr/bin/env bash
# gw.sh - Gamedev-WF harness entry point. One command for every feedback loop.
#
# Works on Linux (Mint, CI) and on Windows inside Git Bash (which is also the
# shell Claude Code uses on Windows).
#
#   ./harness/gw.sh import            re-import assets, rebuild class cache
#   ./harness/gw.sh test [tier] [f]   run tests: tier = unit|sim|scene|all, f = name filter
#   ./harness/gw.sh smoke [frames]    boot the main scene headless for N frames, fail on script errors
#   ./harness/gw.sh sim [args...]     headless balance runs, e.g. --seeds=1-20 --ticks=800
#   ./harness/gw.sh shot [scene] [frames]  render real frames to reports/shots/ (needs a display or xvfb)
#   ./harness/gw.sh check             the gate: import + all tests + smoke  (run before every commit)
#   ./harness/gw.sh doc               dump the Godot API reference of YOUR Godot version to docs/ref/
#   ./harness/gw.sh export <preset> <out>  export a build (needs export templates + export_presets.cfg)
#   ./harness/gw.sh version           print the Godot version in use
#
# Godot binary: $GODOT if set, else `godot`, else `godot4` on PATH.
# On Windows point GODOT at the *_console.exe build, otherwise you get no output.

set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR" || exit 2
REPORTS="$PROJECT_DIR/reports"
LOGS="$REPORTS/logs"
mkdir -p "$LOGS"

find_godot() {
  if [[ -n "${GODOT:-}" ]]; then echo "$GODOT"; return; fi
  for c in godot godot4; do
    if command -v "$c" >/dev/null 2>&1; then echo "$c"; return; fi
  done
  echo ""
}
GODOT_BIN="$(find_godot)"
if [[ -z "$GODOT_BIN" ]]; then
  echo "HARNESS: Godot not found. Install Godot 4 and put it on PATH as 'godot', or set GODOT=/path/to/godot" >&2
  exit 2
fi

# Run Godot, keep a log, and fail on script/parse errors even if Godot exits 0.
run_godot() {
  local log="$1"; shift
  "$GODOT_BIN" "$@" >"$log" 2>&1
  local code=$?
  # print the log, minus noisy engine banner lines
  grep -v -E '^(Godot Engine v|OpenGL API|Vulkan API|WARNING: Detected another project.godot)' "$log" || true
  if grep -q -E 'SCRIPT ERROR|Parse Error|Failed to load script|Invalid call|Invalid access' "$log"; then
    echo "HARNESS: script errors found in output -> FAIL (full log: ${log#$PROJECT_DIR/})"
    [[ $code -eq 0 ]] && code=1
  fi
  return $code
}

cmd_import() {
  # --import imports resources and builds the global class cache, then quits.
  "$GODOT_BIN" --headless --path . --import >"$LOGS/import.log" 2>&1
  local code=$?
  if grep -q -E 'SCRIPT ERROR|Parse Error' "$LOGS/import.log"; then
    grep -E 'SCRIPT ERROR|Parse Error|at: ' "$LOGS/import.log"
    echo "HARNESS: import found script errors (log: reports/logs/import.log)"
    return 1
  fi
  [[ $code -ne 0 ]] && echo "HARNESS: import exited with $code (log: reports/logs/import.log)"
  return $code
}

cmd_test() {
  local tier="${1:-all}" filter="${2:-}"
  local extra=()
  [[ -n "$filter" ]] && extra+=("--filter=$filter")
  [[ -n "${GW_VERBOSE:-}" ]] && extra+=("--verbose")
  run_godot "$LOGS/test_$tier.log" --headless --path . -s res://harness/test_runner.gd -- "--tier=$tier" "${extra[@]}"
}

cmd_smoke() {
  local frames="${1:-300}"
  run_godot "$LOGS/smoke.log" --headless --path . --quit-after "$frames"
  local code=$?
  local errs
  errs=$(grep -c -E '^(ERROR|USER ERROR):' "$LOGS/smoke.log" || true)
  if [[ "$errs" != "0" ]]; then
    echo "HARNESS: smoke run printed $errs ERROR line(s) - read reports/logs/smoke.log"
    [[ $code -eq 0 ]] && code=1
  fi
  [[ $code -eq 0 ]] && echo "SMOKE OK: main scene ran $frames frames without errors"
  return $code
}

cmd_sim() {
  run_godot "$LOGS/sim.log" --headless --path . -s res://harness/sim_runner.gd -- "$@"
}

cmd_shot() {
  local scene="${1:-}" frames="${2:-60}"
  local dir="$REPORTS/shots/$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$dir"
  local args=(--path . --rendering-method gl_compatibility --fixed-fps 30 --quit-after "$frames" --write-movie "$dir/frame.png")
  [[ -n "$scene" ]] && args+=("$scene")
  local runner=()
  if [[ "$(uname -s)" == "Linux" && -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    if command -v xvfb-run >/dev/null 2>&1; then
      runner=(xvfb-run -a -s "-screen 0 1280x720x24")
    else
      echo "HARNESS: no display and no xvfb-run. Install it: sudo apt install xvfb" >&2
      return 2
    fi
  fi
  "${runner[@]}" "$GODOT_BIN" "${args[@]}" >"$LOGS/shot.log" 2>&1
  local code=$?
  local last
  last=$(ls -1 "$dir"/*.png 2>/dev/null | tail -n 1)
  if [[ -z "$last" ]]; then
    echo "HARNESS: no frames written (log: reports/logs/shot.log)"; return 1
  fi
  # keep 3 evenly spaced frames, drop the rest to save disk
  local all=("$dir"/*.png); local n=${#all[@]}
  local keep=("${all[0]}" "${all[$((n/2))]}" "${all[$((n-1))]}")
  for f in "${all[@]}"; do
    [[ " ${keep[*]} " == *" $f "* ]] || rm -f "$f"
  done
  echo "SHOTS ${dir#$PROJECT_DIR/}:"
  for f in "${keep[@]}"; do echo "  ${f#$PROJECT_DIR/}"; done
  return $code
}

cmd_check() {
  cmd_import || return $?
  cmd_test all || return $?
  cmd_smoke 300 || return $?
  echo "CHECK OK"
}

cmd_doc() {
  local out="$PROJECT_DIR/docs/ref/godot-api"
  mkdir -p "$out"
  "$GODOT_BIN" --headless --doctool "$out" >"$LOGS/doc.log" 2>&1
  echo "API reference for $("$GODOT_BIN" --version) written to docs/ref/godot-api ($(find "$out" -name '*.xml' | wc -l) classes)"
  echo "Tip: grep -l 'name=\"TileMapLayer\"' -r docs/ref/godot-api"
}

cmd_export() {
  local preset="${1:?usage: gw.sh export <preset name> <output file>}" out="${2:?output file}"
  mkdir -p "$(dirname "$out")"
  run_godot "$LOGS/export.log" --headless --path . --export-release "$preset" "$out"
}

case "${1:-help}" in
  import)  shift; cmd_import "$@" ;;
  test)    shift; cmd_test "$@" ;;
  smoke)   shift; cmd_smoke "$@" ;;
  sim)     shift; cmd_sim "$@" ;;
  shot)    shift; cmd_shot "$@" ;;
  check)   shift; cmd_check "$@" ;;
  doc)     shift; cmd_doc "$@" ;;
  export)  shift; cmd_export "$@" ;;
  version) "$GODOT_BIN" --version ;;
  *) sed -n '2,20p' "$0" ;;
esac
