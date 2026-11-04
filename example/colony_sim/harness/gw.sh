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
#   ./harness/gw.sh hooks             install a git pre-commit hook that runs `precommit`
#   ./harness/gw.sh precommit         the gate, skipped when only docs (*.md, docs/, ideas/) are staged
#   ./harness/gw.sh version           print the harness and Godot versions
#
# Godot binary: $GODOT if set, else `godot`, else `godot4` on PATH.
# On Windows point GODOT at the *_console.exe build, otherwise you get no output.
# Limits: GW_TIMEOUT (default 900 s) kills any single Godot run that hangs;
#         GW_TEST_TIMEOUT (default 60 s) fails a single test that waits forever.

set -uo pipefail

HARNESS_VERSION="1.1.0"

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
if [[ -z "$GODOT_BIN" && "${1:-}" != "precommit" && "${1:-}" != "hooks" && "${1:-}" != "help" ]]; then
  echo "HARNESS: Godot not found. Install Godot 4 and put it on PATH as 'godot', or set GODOT=/path/to/godot" >&2
  exit 2
fi

# Hard time limit per Godot run, so an endless loop cannot stall an unattended
# agent for hours. Uses coreutils `timeout` (Linux, Git Bash); skipped if missing.
GW_TIMEOUT="${GW_TIMEOUT:-900}"
LIMIT=()
if [[ "$GW_TIMEOUT" != "0" ]] && timeout --version >/dev/null 2>&1; then
  LIMIT=(timeout --kill-after=10 "$GW_TIMEOUT")
fi

# Run the Godot binary under the time limit.
godot_limited() {
  "${LIMIT[@]}" "$GODOT_BIN" "$@"
}

# Print a hint if exit code $1 means the time limit stopped Godot.
explain_timeout() {
  if [[ ${#LIMIT[@]} -gt 0 && ( $1 -eq 124 || $1 -eq 137 ) ]]; then
    echo "HARNESS: Godot was stopped after ${GW_TIMEOUT}s (endless loop? raise GW_TIMEOUT for long runs) -> FAIL"
  fi
}

# Run Godot, keep a log, print it (minus engine banner lines) and fail on
# script/parse errors even if Godot exits 0. With HIDE_PASSING_ERRORS set, a
# passing run folds ERROR blocks into one line: in a passing test run every
# error was declared with expect_error(), otherwise a test would have failed.
run_godot() {
  local log="$1"; shift
  godot_limited "$@" >"$log" 2>&1
  local code=$?
  local script_err=0
  if grep -q -E 'SCRIPT ERROR|Parse Error|Failed to load script|Invalid call|Invalid access' "$log"; then
    script_err=1
    [[ $code -eq 0 ]] && code=1
  fi
  local shown
  shown=$(grep -v -E '^(Godot Engine v|OpenGL API|Vulkan API|WARNING: Detected another project.godot)' "$log")
  if [[ $code -eq 0 && -n "${HIDE_PASSING_ERRORS:-}" ]]; then
    shown=$(awk -v logf="${log#"$PROJECT_DIR"/}" '
      /^(USER )?ERROR: / { skip = 1; n++; next }
      skip && /^[[:space:]]/ { next }
      { skip = 0; print }
      END { if (n > 0) printf "(%d expected error message(s) hidden, all declared with expect_error - log: %s)\n", n, logf }' <<<"$shown")
  fi
  [[ -n "$shown" ]] && echo "$shown"
  explain_timeout $code
  if [[ $script_err -eq 1 ]]; then
    echo "HARNESS: script errors found in output -> FAIL (full log: ${log#"$PROJECT_DIR"/})"
  fi
  return $code
}

cmd_import() {
  # --import imports resources and builds the global class cache, then quits.
  godot_limited --headless --path . --import >"$LOGS/import.log" 2>&1
  local code=$?
  explain_timeout $code
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
  [[ -n "${GW_TEST_TIMEOUT:-}" ]] && extra+=("--timeout=$GW_TEST_TIMEOUT")
  local hide=1
  [[ -n "${GW_VERBOSE:-}" ]] && hide=""
  HIDE_PASSING_ERRORS=$hide run_godot "$LOGS/test_$tier.log" --headless --path . -s res://harness/test_runner.gd -- "--tier=$tier" "${extra[@]}"
  local code=$?
  if ! grep -q '^RESULT ' "$LOGS/test_$tier.log"; then
    echo "HARNESS: the test run ended without a RESULT line (crash or hang) -> FAIL (log: reports/logs/test_$tier.log)"
    [[ $code -eq 0 ]] && code=1
  fi
  return $code
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
  local code=$?
  if ! grep -q '^SIM ' "$LOGS/sim.log"; then
    echo "HARNESS: the sim run ended without a summary (crash or hang) -> FAIL (log: reports/logs/sim.log)"
    [[ $code -eq 0 ]] && code=1
  fi
  return $code
}

cmd_shot() {
  local scene="${1:-}" frames="${2:-60}"
  local dir
  dir="$REPORTS/shots/$(date +%Y%m%d_%H%M%S)"
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
  "${runner[@]}" "${LIMIT[@]}" "$GODOT_BIN" "${args[@]}" >"$LOGS/shot.log" 2>&1
  local code=$?
  explain_timeout $code
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

# Called by the git pre-commit hook. Commits that only touch docs skip the
# gate, so a quick /wrap-up or GDD edit stays fast.
# Note: it checks the working tree, which is what the agent just tested.
cmd_precommit() {
  local staged
  staged=$(git diff --cached --name-only --relative 2>/dev/null)
  if [[ -z "$staged" ]] || ! grep -q -v -E '^(docs/|ideas/)|\.md$' <<<"$staged"; then
    echo "PRECOMMIT: only docs staged here - gate skipped"
    return 0
  fi
  if [[ -z "$GODOT_BIN" ]]; then
    echo "PRECOMMIT: Godot not found (set GODOT) - cannot run the gate -> commit blocked"
    return 2
  fi
  echo "PRECOMMIT: running the gate (gw.sh check)..."
  if ! cmd_check; then
    echo "PRECOMMIT: gate failed -> commit blocked. Fix it, or record it under Blocked in docs/LOG.md."
    return 1
  fi
}

# Install .git/hooks/pre-commit -> gw.sh precommit. Run once per clone
# (git does not copy hooks), e.g. by /harness and /commission.
cmd_hooks() {
  local prefix hook
  if ! prefix=$(git rev-parse --show-prefix 2>/dev/null); then
    echo "HARNESS: not a git repository - run git init first"; return 2
  fi
  hook="$(git rev-parse --git-path hooks)/pre-commit"
  if [[ -f "$hook" ]] && ! grep -q 'gw.sh precommit' "$hook"; then
    echo "HARNESS: $hook exists and was not written by the harness. Add this line to it yourself:"
    echo "  cd \"\$(git rev-parse --show-toplevel)/$prefix\" && ./harness/gw.sh precommit || exit 1"
    return 1
  fi
  mkdir -p "$(dirname "$hook")"
  {
    echo '#!/usr/bin/env bash'
    echo '# Installed by ./harness/gw.sh hooks - the harness gate before every commit.'
    echo "cd \"\$(git rev-parse --show-toplevel)/$prefix\" && exec ./harness/gw.sh precommit"
  } >"$hook"
  chmod +x "$hook"
  echo "HOOK installed ($hook): commits that change code, data or tests now run gw.sh check first"
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
  precommit) cmd_precommit ;;
  hooks)   cmd_hooks ;;
  version) echo "Gamedev-WF harness $HARNESS_VERSION"; "$GODOT_BIN" --version ;;
  *) sed -n '2,23p' "$PROJECT_DIR/harness/gw.sh" ;;
esac
