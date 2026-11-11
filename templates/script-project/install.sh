#!/usr/bin/env bash
#
# install.sh — 安装 {{项目名}} 的入口到 ~/.local/bin
#
# 用法:
#   ./install.sh              安装（重复执行安全）
#   ./install.sh --check      校验已装副本与仓库一致
#   ./install.sh --uninstall  卸载
#
# 约定: 只写用户目录，不动系统路径，不需要 sudo。

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
target_dir=${XDG_BIN_HOME:-$HOME/.local/bin}
name=example

usage() { sed -n '3,10p' "$0" | sed 's/^# \{0,1\}//'; }

install_entry() {
  install -Dm755 "$here/bin/$name" "$target_dir/$name"
  printf 'installed: %s\n' "$target_dir/$name"
  printf '确保 %s 在 PATH 里。\n' "$target_dir"
}

check_entry() {
  if [[ ! -e $target_dir/$name ]]; then
    printf '未安装: %s\n' "$target_dir/$name" >&2
    exit 1
  fi
  if cmp -s "$here/bin/$name" "$target_dir/$name"; then
    printf 'ok: 已装副本与仓库一致\n'
  else
    printf 'drift: 已装副本与仓库不一致，重跑 ./install.sh\n' >&2
    exit 1
  fi
}

uninstall_entry() {
  rm -f "$target_dir/$name"
  printf 'removed: %s\n' "$target_dir/$name"
}

case "${1:-}" in
  ''|--install) install_entry ;;
  --check) check_entry ;;
  --uninstall) uninstall_entry ;;
  -h|--help) usage ;;
  *) printf '未知参数: %s\n' "$1" >&2; usage >&2; exit 2 ;;
esac
