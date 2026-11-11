#!/usr/bin/env bash
#
# build.sh — {{包名}} 的统一入口：makepkg 的薄封装
#
# 用法:
#   ./build.sh            构建并安装
#   ./build.sh --force    强制重新编译
#   其余参数原样传给 makepkg

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
cd "$here"

exec makepkg -si "$@"
