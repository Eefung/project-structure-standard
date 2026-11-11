#!/usr/bin/env bash
#
# test-layout.sh — check-layout.sh 的回归测试
#
# 每个用例在临时目录里造一个 fixture 仓库，改一处让它违规，
# 断言检查器给出预期退出码与提示。全部在 mktemp -d 下进行，结束后清理。
#
# 用法：tests/test-layout.sh

set -uo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)
checker=$here/scripts/check-layout.sh
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

pass=0
fail=0

# 造一个满足全部必需项的 fixture；$1 为子目录名
new_fixture() {
  local dir=$tmp/$1
  mkdir -p "$dir/docs"
  cat >"$dir/README.md" <<'MD'
# Fixture Tool

A tiny fixture used by the layout checker's tests.

## How it works

Nothing at all.

## Installation

```sh
./run.sh
```

## Usage

```sh
./run.sh
```

## Documentation

See `docs/note.md`.

## License

MIT.
MD
  printf '#!/bin/sh\nexit 0\n' >"$dir/run.sh"
  chmod +x "$dir/run.sh"
  printf 'MIT\n' >"$dir/LICENSE"
  printf '*.tar.xz\n' >"$dir/.gitignore"
  printf '# note\n' >"$dir/docs/note.md"
  git -C "$dir" init -q
  git -C "$dir" add -A
  git -C "$dir" -c user.name=t -c user.email=t@example.com commit -qm 'feat: fixture'
  printf '%s\n' "$dir"
}

# 中文 fixture：中文标题 + 中文正文
new_fixture_cn() {
  local dir=$tmp/$1
  mkdir -p "$dir/docs"
  cat >"$dir/README.md" <<'MD'
# 示例工具

一个用来测布局检查器的中文 fixture。

## 原理

什么都不做。

## 安装

```sh
./run.sh
```

## 用法

```sh
./run.sh
```

## 文档

见 `docs/note.md`。

## 许可

MIT。
MD
  printf '#!/bin/sh\nexit 0\n' >"$dir/run.sh"
  chmod +x "$dir/run.sh"
  printf 'MIT\n' >"$dir/LICENSE"
  printf '*.tar.xz\n' >"$dir/.gitignore"
  printf '# note\n' >"$dir/docs/note.md"
  git -C "$dir" init -q
  git -C "$dir" add -A
  git -C "$dir" -c user.name=t -c user.email=t@example.com commit -qm 'feat: fixture'
  printf '%s\n' "$dir"
}

# run_case <描述> <期望退出码> <输出中必须出现的片段> <仓库目录>
run_case() {
  local name=$1 want=$2 pattern=$3 dir=$4 out code
  out=$("$checker" --quiet "$dir" 2>&1)
  code=$?
  if [[ $code -eq $want ]] && grep -qF -- "$pattern" <<<"$out"; then
    printf '  ✓ %s\n' "$name"
    pass=$((pass + 1))
  else
    printf '  ✗ %s（期望 exit=%s 且输出含「%s」，实得 exit=%s）\n' "$name" "$want" "$pattern" "$code"
    printf '%s\n' "$out" | sed 's/^/      /'
    fail=$((fail + 1))
  fi
}

# 同 run_case，但不用 --quiet，用于断言告警文案
run_case_v() {
  local name=$1 want=$2 pattern=$3 dir=$4 out code
  out=$("$checker" "$dir" 2>&1)
  code=$?
  if [[ $code -eq $want ]] && grep -qF -- "$pattern" <<<"$out"; then
    printf '  ✓ %s\n' "$name"
    pass=$((pass + 1))
  else
    printf '  ✗ %s（期望 exit=%s 且输出含「%s」，实得 exit=%s）\n' "$name" "$want" "$pattern" "$code"
    printf '%s\n' "$out" | sed 's/^/      /'
    fail=$((fail + 1))
  fi
}

printf '== test-layout: %s\n' "$checker"

d=$(new_fixture base)
run_case '合规 fixture 通过' 0 '全部通过' "$d"

d=$(new_fixture no-license)
rm "$d/LICENSE"
run_case '缺 LICENSE 必须失败' 1 'R1' "$d"

d=$(new_fixture no-exec)
chmod -x "$d/run.sh"
run_case '入口缺执行位必须失败' 1 '不可执行' "$d"

d=$(new_fixture missing-entry)
printf '\n```sh\n./missing.sh\n```\n' >>"$d/README.md"
run_case 'README 代码块指向不存在的脚本必须失败' 1 '不存在' "$d"

d=$(new_fixture bad-docname)
printf '# x\n' >"$d/docs/Bad_Name.md"
run_case 'docs/ 非 kebab-case 必须失败' 1 'kebab' "$d"

d=$(new_fixture handoff)
printf '# handoff\n' >"$d/HANDOFF.md"
run_case '交接文档不在 docs/handoff.md 必须失败' 1 'handoff.md' "$d"

d=$(new_fixture leak)
printf 'x\n' >"$d/.gitignore"          # 清空忽略规则
printf 'x' >"$d/payload.tar.xz"
run_case '工作区产物未被忽略必须失败' 1 '未被忽略' "$d"

d=$(new_fixture tracked)
printf 'x' >"$d/big.pkg.tar.zst"
git -C "$d" add -f big.pkg.tar.zst
run_case '产物已入库必须失败' 1 '已入库' "$d"

d=$(new_fixture ignored-artifact)
printf 'x' >"$d/payload.tar.xz"        # *.tar.xz 已被 .gitignore 覆盖
run_case '已忽略的产物只告警，不阻塞' 0 '全部通过' "$d"

d=$(new_fixture readme-sections)
grep -v '^## Documentation' "$d/README.md" >"$d/README.tmp" && mv "$d/README.tmp" "$d/README.md"
run_case '缺 Documentation 小节必须失败' 1 'Documentation' "$d"

d=$(new_fixture no-h1)
sed '1d' "$d/README.md" >"$d/README.tmp" && mv "$d/README.tmp" "$d/README.md"
run_case '缺一级标题必须失败' 1 '一级标题' "$d"

d=$(new_fixture no-overview)
grep -v '^A tiny fixture' "$d/README.md" >"$d/README.tmp" && mv "$d/README.tmp" "$d/README.md"
run_case 'H1 下无简介必须失败' 1 '简介' "$d"

d=$(new_fixture bad-order)
sed -e 's/^## Installation$/## SWAP/' -e 's/^## Usage$/## Installation/' -e 's/^## SWAP$/## Usage/' \
    "$d/README.md" >"$d/README.tmp" && mv "$d/README.tmp" "$d/README.md"
run_case '章节顺序错乱必须失败' 1 '顺序' "$d"

d=$(new_fixture license-not-last)
printf '\n## Appendix\n\nAppendix text.\n' >>"$d/README.md"
run_case 'License 之后还有小节必须失败' 1 '最后一节' "$d"

d=$(new_fixture extra-section)
sed -i '/^## License/i ## Troubleshooting\n\nTroubleshooting notes.\n' "$d/README.md"
run_case '规范外的二级标题只告警，不阻塞' 0 '全部通过' "$d"

d=$(new_fixture_cn cn-ok)
run_case '中文文档用中文标题应通过' 0 '全部通过' "$d"

d=$(new_fixture_cn cn-en-headings)
sed -i -e 's/^## 原理$/## How it works/' -e 's/^## 安装$/## Installation/' \
       -e 's/^## 用法$/## Usage/' -e 's/^## 文档$/## Documentation/' -e 's/^## 许可$/## License/' \
       "$d/README.md"
run_case '中文正文配英文标题必须失败' 1 '中文标题' "$d"

d=$(new_fixture_cn cn-verbose-heading)
sed -i 's/^## 原理$/## 工作原理/' "$d/README.md"
run_case '中文标题写「工作原理」必须失败' 1 '缺少小节' "$d"

d=$(new_fixture_cn cn-quickstart)
sed -i 's/^## 用法$/## 快速开始/' "$d/README.md"
run_case '中文标题写「快速开始」必须失败' 1 '缺少小节' "$d"

d=$(new_fixture en-cn-headings)
sed -i -e 's/^## How it works$/## 工作原理/' -e 's/^## Installation$/## 安装/' \
       -e 's/^## Usage$/## 用法/' -e 's/^## Documentation$/## 文档/' -e 's/^## License$/## 许可/' \
       "$d/README.md"
run_case '英文正文配中文标题必须失败' 1 '英文标题' "$d"

d=$(new_fixture slug-title)
sed -i '1s/.*/# fixture-repo/' "$d/README.md"
run_case 'H1 用仓库 slug 必须失败' 1 'slug' "$d"

d=$(new_fixture install-short)
sed -i 's/^## Installation$/## Install/' "$d/README.md"
run_case_v 'Install 可接受但提示改用 Installation' 0 'Installation' "$d"

d=$(new_fixture nested-handoff)
mkdir -p "$d/templates/thing/docs"
printf '# handoff\n' >"$d/templates/thing/docs/handoff.md"
run_case '嵌套在模板里的 handoff 不算违规' 0 '全部通过' "$d"

printf '\n== 结果：%d 通过，%d 失败\n' "$pass" "$fail"
((fail == 0)) && exit 0 || exit 1
