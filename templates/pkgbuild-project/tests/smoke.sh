#!/usr/bin/env bash
#
# smoke.sh — 最小回归测试：PKGBUILD 可被解析且必备字段齐全，build.sh 语法正确
#
# 用法: tests/smoke.sh

set -uo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)
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

check 'build.sh 语法正确' bash -n "$here/build.sh"
check 'PKGBUILD 可被 bash 解析' bash -c "source '$here/PKGBUILD'"
check 'pkgname 已填写' bash -c "source '$here/PKGBUILD'; [[ -n \$pkgname ]]"
check 'pkgver / pkgrel / arch / license 已填写' \
  bash -c "source '$here/PKGBUILD'; [[ -n \$pkgver && -n \$pkgrel && \${#arch[@]} -gt 0 && \${#license[@]} -gt 0 ]]"
check 'source 与 sha256sums 数量一致' \
  bash -c "source '$here/PKGBUILD'; [[ \${#source[@]} -eq \${#sha256sums[@]} ]]"

printf '\n== %d 通过，%d 失败\n' "$pass" "$fail"
((fail == 0)) && exit 0 || exit 1
