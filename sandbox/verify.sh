#!/usr/bin/env bash
# verify.sh — sanity check that sandbox-agent enforces its constraints.
#
# Run from the directory containing `sandbox-agent`:
#     ./verify.sh
#
# Exits 0 if all tests pass, 1 otherwise. Output shows PASS/FAIL per test.
#
# Tests cover: filesystem isolation, network allowlist, git-mutation shim,
# PID namespace, hostname, cleanup on exit. No live-fire test against the
# real Claude API (that lives separately — run `sandbox-claude -p "say OK"`
# and watch the proxy log for `CONNECT api.anthropic.com:443`).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
SBA="$SCRIPT_DIR/sandbox-agent"
RUN_DIR_PATTERN='/run/user/'"$(id -u)"'/sandbox-agent.*'

if [[ ! -x "$SBA" ]]; then
  echo "verify.sh: cannot find executable $SBA" >&2
  exit 2
fi

pass=0
fail=0
fails=()

# run_test NAME EXPECT_SUBSTRING CMD [extra sandbox-agent args...]
# Runs CMD inside `sandbox-agent shell`, checks the combined output contains
# EXPECT_SUBSTRING. Passes any extra args to sandbox-agent (e.g. --allow host).
run_test() {
  local name="$1"; shift
  local expect="$1"; shift
  local cmd="$1"; shift
  local out ec
  echo "--- $name ---"
  out=$("$SBA" shell "$@" -c "$cmd" 2>&1; echo "__EC=$?__")
  echo "$out" | grep -v '^__EC=' | head -3
  if grep -qF -- "$expect" <<<"$out"; then
    echo "PASS"
    pass=$((pass+1))
  else
    echo "FAIL — expected substring: $expect"
    fail=$((fail+1))
    fails+=( "$name" )
  fi
  echo
}

# host_check NAME EXPECT_EMPTY_OR_NOT CMD
# Runs CMD on the host (not inside sandbox) and asserts whether its output
# is empty. Used to check post-exit cleanup.
host_check_empty() {
  local name="$1"; shift
  local cmd="$1"; shift
  local out
  echo "--- $name ---"
  out=$(eval "$cmd" 2>/dev/null || true)
  if [[ -z "$out" ]]; then
    echo "PASS (no output)"
    pass=$((pass+1))
  else
    echo "FAIL — expected empty, got:"
    echo "$out" | head -5
    fail=$((fail+1))
    fails+=( "$name" )
  fi
  echo
}

echo "================================================================"
echo " sandbox-agent verification suite"
echo " script under test: $SBA"
echo "================================================================"
echo

# --- Filesystem isolation ---
run_test "T1  CWD is writable" \
  "OK_INSIDE" \
  'echo OK_INSIDE > inside.txt && cat inside.txt && rm inside.txt'

run_test "T2  HOME is read-only" \
  "Read-only file system" \
  "echo a > $HOME/.sandbox-verify-should-fail 2>&1; true"

run_test "T3  /etc is read-only" \
  "Read-only file system" \
  'echo a > /etc/hosts 2>&1; true'

run_test "T4  /tmp is fresh tmpfs (not host /tmp)" \
  "ISOLATED" \
  'count=$(ls -A /tmp 2>/dev/null | wc -l); [[ "$count" -le 1 ]] && echo ISOLATED || echo "LEAKED $count host entries"'

# --- Namespaces & identity ---
run_test "T5  PID namespace is isolated (bwrap as PID 1)" \
  "bwrap" \
  'ps -ef | head -3'

run_test "T6  hostname is sandbox-agent" \
  "sandbox-agent" \
  'cat /proc/sys/kernel/hostname'

run_test "T7  HTTPS_PROXY env var set" \
  "http://127.0.0.1:" \
  'echo "$HTTPS_PROXY"'

# --- Git mutation shim ---
run_test "T8  git push blocked by shim" \
  "sandbox-agent: blocked: git push" \
  'git push origin main 2>&1; true'

run_test "T9  git remote add blocked by shim" \
  "sandbox-agent: blocked: git remote add" \
  'git remote add origin https://example.com/x.git 2>&1; true'

run_test "T10 git send-email blocked by shim" \
  "sandbox-agent: blocked: git send-email" \
  'git send-email /dev/null 2>&1; true'

run_test "T11 git --version allowed (read-only)" \
  "git version" \
  'git --version 2>&1; true'

run_test "T12 git config remote.* blocked" \
  "sandbox-agent: blocked" \
  'git config remote.origin.url https://x/y 2>&1; true'

# --- Network allowlist ---
run_test "T13 unallowed host blocked by proxy" \
  "403" \
  'curl -sS -o /dev/null -w "%{http_code}\n" --max-time 8 https://example.com/ 2>&1; true'

run_test "T14 allowed host reaches origin" \
  "Connection established" \
  'curl -sS -i --max-time 8 https://api.anthropic.com/ 2>&1 | head -3' \
  --allow api.anthropic.com

# --- Spec edge cases ---
run_test "T17 CWD subdirectories are writable" \
  "OK_SUBDIR" \
  'mkdir -p sub/nested && echo OK_SUBDIR > sub/nested/file && cat sub/nested/file && rm -rf sub'

# Poison sensitive env vars and confirm --clearenv strips them. HOME and
# HTTPS_PROXY are positive controls — they should be present (re-set by the
# script). All four assertions must match in a single line.
ANTHROPIC_API_KEY="POISON_AK" SSH_AUTH_SOCK="/poison/sock" POISON_VAR="leak" \
  GITHUB_TOKEN="POISON_GH" \
run_test "T18 sensitive env vars scrubbed by --clearenv" \
  "AK=UNSET SSH=UNSET POI=UNSET GH=UNSET HOME=SET PROXY=SET" \
  'echo "AK=${ANTHROPIC_API_KEY-UNSET} SSH=${SSH_AUTH_SOCK-UNSET} POI=${POISON_VAR-UNSET} GH=${GITHUB_TOKEN-UNSET} HOME=$([[ -n ${HOME:-} ]] && echo SET || echo UNSET) PROXY=$([[ -n ${HTTPS_PROXY:-} ]] && echo SET || echo UNSET)"'

run_test "T19 non-443 CONNECT port blocked by proxy" \
  "403" \
  'curl -sS -o /dev/null -w "%{http_code}\n" --max-time 8 https://api.anthropic.com:8080/ 2>&1; true' \
  --allow api.anthropic.com

SANDBOX_AGENT_ALLOW_HOSTS="api.anthropic.com" \
run_test "T20 SANDBOX_AGENT_ALLOW_HOSTS env var adds to allowlist" \
  "Connection established" \
  'curl -sS -i --max-time 8 https://api.anthropic.com/ 2>&1 | head -3'

run_test "T21 git submodule add blocked by shim" \
  "sandbox-agent: blocked: git submodule add" \
  'git submodule add https://example.com/x.git deps/x 2>&1; true'

# Universal localhost allowlist: should reach loopback in all its forms,
# regardless of profile or --no-default-allow. We use port 1 (reserved,
# nothing ever listens) and assert curl gets "Failed to connect" from the
# kernel — not "403" from the proxy.
run_test "T22a 127.0.0.1 loopback bypasses proxy" \
  "Failed to connect" \
  'curl -sS --max-time 3 http://127.0.0.1:1/ 2>&1; true'

run_test "T22b ::1 IPv6 loopback bypasses proxy" \
  "Failed to connect" \
  'curl -sS --max-time 3 "http://[::1]:1/" 2>&1; true'

run_test "T22c 127.0.0.x loopback aliases bypass proxy" \
  "Failed to connect" \
  'curl -sS --max-time 3 http://127.0.0.2:1/ 2>&1; true'

run_test "T22d localhost still allowed with --no-default-allow" \
  "Failed to connect" \
  'curl -sS --max-time 3 http://127.0.0.1:1/ 2>&1; true' \
  --no-default-allow

# Regression guards: previous shim version had bugs in these argv shapes.
run_test "T22 git -C dir push blocked (global flag before subcommand)" \
  "sandbox-agent: blocked: git -C /tmp push" \
  'git -C /tmp push origin main 2>&1; true'

run_test "T23 git remote -v rm blocked (flag between subcommand and action)" \
  "sandbox-agent: blocked: git remote -v rm" \
  'git remote -v rm origin 2>&1; true'

# --- Post-exit cleanup ---
host_check_empty "T24 no leftover tinyproxy processes" \
  "pgrep -af 'tinyproxy.*sandbox-agent' | grep -v pgrep"

host_check_empty "T25 no leftover runroots in XDG_RUNTIME_DIR" \
  "ls -d $RUN_DIR_PATTERN 2>/dev/null"

# --- Report ---
total=$((pass+fail))
echo "================================================================"
echo " RESULTS: $pass / $total passed"
if (( fail > 0 )); then
  echo " FAILED tests:"
  printf '   - %s\n' "${fails[@]}"
fi
echo "================================================================"

exit $(( fail == 0 ? 0 : 1 ))
