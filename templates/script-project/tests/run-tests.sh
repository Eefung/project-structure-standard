#!/usr/bin/env bash
#
# run-tests.sh — 最小回归测试：入口可执行、安装/校验/卸载闭环可用
#
# 用法: tests/run-tests.sh

set -uo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

pass=0
fail=0
check() {
  local name=$1
  shift
  if "$@" >/dev/null 2>&1; then
    printf '  ✓ %s\n' "$name"
    pass=$((pass + 1))
  else
    printf '  ✗ %s\n' "$name"
    fail=$((fail + 1))
  fi
}

check 'bin/example 可执行' test -x "$here/bin/example"

XDG_BIN_HOME=$tmp "$here/install.sh" >/dev/null 2>&1
check '安装后入口落地' test -x "$tmp/example"

check '--check 认可一致副本' env XDG_BIN_HOME=$tmp "$here/install.sh" --check

printf 'x\n' >>"$tmp/example"
check '--check 检出漂移' bash -c "! XDG_BIN_HOME=$tmp '$here/install.sh' --check"

XDG_BIN_HOME=$tmp "$here/install.sh" --uninstall >/dev/null 2>&1
check '--uninstall 之后入口消失' test ! -e "$tmp/example"

printf '\n== %d 通过，%d 失败\n' "$pass" "$fail"
((fail == 0)) && exit 0 || exit 1
