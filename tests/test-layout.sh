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
# fixture

## 问题

演示用 fixture。

## 做法

什么都不做。

## 用法

```sh
./run.sh
```

## 验证

看完即通过。

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
grep -v '^## 验证' "$d/README.md" >"$d/README.tmp" && mv "$d/README.tmp" "$d/README.md"
run_case 'README 缺验证小节必须失败' 1 '验证' "$d"

d=$(new_fixture nested-handoff)
mkdir -p "$d/templates/thing/docs"
printf '# handoff\n' >"$d/templates/thing/docs/handoff.md"
run_case '嵌套在模板里的 handoff 不算违规' 0 '全部通过' "$d"

printf '\n== 结果：%d 通过，%d 失败\n' "$pass" "$fail"
((fail == 0)) && exit 0 || exit 1
