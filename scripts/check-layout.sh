#!/usr/bin/env bash
#
# check-layout.sh — 检查仓库是否符合 project-structure-standard 的目录约定
#
# 用法：
#   scripts/check-layout.sh [选项] [仓库路径]
#
# 选项：
#   -q, --quiet   只输出失败项与汇总
#   -h, --help    显示本帮助
#
# 退出码：
#   0  必需项全部通过（推荐项可能仍有告警）
#   1  有必需项未通过
#   2  用法错误
#
# 判定口径见 docs/standard.md。规则只在「能由脚本判定」时才进入必需层。

set -uo pipefail

QUIET=0
repo_arg=""
usage() { sed -n '3,20p' "$0" | sed 's/^# \{0,1\}//'; }

while (($#)); do
  case "$1" in
    -q|--quiet) QUIET=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) printf '未知选项: %s\n' "$1" >&2; exit 2 ;;
    *) repo_arg="$1" ;;
  esac
  shift
done

repo_arg=${repo_arg:-.}
if [[ ! -d $repo_arg ]]; then
  printf '不是目录: %s\n' "$repo_arg" >&2
  exit 2
fi
repo=$(cd "$repo_arg" && pwd)

fails=0
warns=0

ok()   { ((QUIET)) || printf '  ✓ %s\n' "$*"; }
bad()  { fails=$((fails + 1)); printf '  ✗ %s\n' "$*"; }
warn() { warns=$((warns + 1)); ((QUIET)) || printf '  · %s\n' "$*"; }
detail() { ((QUIET)) || printf '      %s\n' "$*"; }

printf '== check-layout: %s\n' "$repo"

# ---------------------------------------------------------------------------
# R1 LICENSE
# ---------------------------------------------------------------------------
if [[ -s $repo/LICENSE ]]; then
  ok 'R1 LICENSE 存在且非空'
else
  bad 'R1 缺少 LICENSE（根目录下不存在或为空文件）'
fi

# ---------------------------------------------------------------------------
# R2 README 五段结构
# ---------------------------------------------------------------------------
readme=$repo/README.md
if [[ ! -s $readme ]]; then
  bad 'R2 缺少 README.md'
else
  headings=$(grep -E '^#{1,3} ' "$readme" || true)
  has_section() { grep -Eiq "^#{1,3} .*($1)" <<<"$headings"; }
  missing=""
  has_section '问题|为什么|背景|动机'          || missing+=" 问题"
  has_section '做法|做什么|是什么|原理|方案|组件|怎么' || missing+=" 做法"
  has_section '用法|安装|快速开始|使用|上手'    || missing+=" 用法"
  has_section '验证|自检|验收|测试|诊断'        || missing+=" 验证"
  has_section '许可|licen[cs]e|版权'            || missing+=" 许可"
  if [[ -z $missing ]]; then
    ok 'R2 README 具备 问题/做法/用法/验证/许可 五类小节'
  else
    bad "R2 README 缺少小节:$missing（标题措辞不限，按关键词匹配）"
  fi
fi

# ---------------------------------------------------------------------------
# R3 README 代码块里能照着跑的命令必须真的能跑
#   只判定围栏代码块内的脚本路径：正文里把别的仓库当例子提及不算。
# ---------------------------------------------------------------------------
if [[ -s $readme ]]; then
  tokens=$(awk '/^[[:space:]]*```/ { fence = !fence; next } fence { print }' "$readme" \
           | grep -oE '(\./)?[A-Za-z0-9_][A-Za-z0-9_./-]*\.sh|[A-Za-z0-9_][A-Za-z0-9_./-]*PKGBUILD' \
           | sed 's|^\./||' | sort -u || true)
  entries=0
  broken=0
  while IFS= read -r tok; do
    [[ -z $tok ]] && continue
    case "$tok" in
      .*|*'*'*|*'{'*|/*) continue ;;   # 点开头、通配、模板、绝对路径不判定
    esac
    if [[ ! -e $repo/$tok ]]; then
      bad "R3 README 代码块里的 $tok 不存在"
      broken=$((broken + 1))
      continue
    fi
    entries=$((entries + 1))
    case "$tok" in
      bin/*|scripts/*|tools/*|tests/*) ;;   # 这些目录下的脚本不猜测调用方式
      */*) ;;                               # 多级路径同理
      *)
        if [[ $tok == *.sh && ! -x $repo/$tok ]]; then
          bad "R3 $tok 作为命令出现却不可执行（缺 chmod +x）"
        fi
        ;;
    esac
  done <<<"$tokens"
  if ((broken == 0)); then
    if ((entries > 0)); then
      ok "R3 README 代码块中的入口均存在（$entries 个）"
    else
      bad 'R3 README 代码块未给出任何可执行入口，读者无从起手'
    fi
  fi
fi

# ---------------------------------------------------------------------------
# R4 docs/ 命名与交接文档位置
# ---------------------------------------------------------------------------
if [[ -d $repo/docs ]]; then
  bad_names=0
  while IFS= read -r f; do
    base=$(basename "$f")
    if ! [[ $base =~ ^[a-z0-9]+(-[a-z0-9]+)*\.md$ ]]; then
      bad "R4 docs/$base 不是小写 kebab-case（如 docs/nvenc-runtime-negotiation.md）"
      bad_names=$((bad_names + 1))
    fi
  done < <(find "$repo/docs" -maxdepth 2 -name '*.md' -type f | sort)
  ((bad_names == 0)) && ok 'R4 docs/ 文件名均为小写 kebab-case'

  while IFS= read -r f; do
    rel=${f#"$repo"/}
    if [[ $rel != docs/handoff.md ]]; then
      bad "R4 交接文档位置不合规：$rel（应为 docs/handoff.md）"
    fi
  done < <(find "$repo" -maxdepth 2 -iname 'handoff*.md' -not -path '*/.git/*' | sort)
else
  ok 'R4 无 docs/ 目录（未触发文档命名规则）'
fi

# ---------------------------------------------------------------------------
# R5 构建产物不得入库，且工作区里的产物必须被忽略
#   files/ 是「原样安装的载荷目录」，允许二进制，不按产物判定。
# ---------------------------------------------------------------------------
artifact_globs=('*.pkg.tar.zst' '*.pkg.tar.zst.sig' '*.pkg.tar.xz' '*.tar.xz' '*.tar.gz'
                '*.tar.bz2' '*.tar.zst' '*.AppImage' '*.deb' '*.rpm' '*.o' '*.so' '*.pyc')
in_git=0
git -C "$repo" rev-parse --git-dir >/dev/null 2>&1 && in_git=1

tracked_bad=""
if ((in_git)); then
  while IFS= read -r f; do
    [[ $f == files/* ]] && continue
    for g in "${artifact_globs[@]}"; do
      # shellcheck disable=SC2053
      if [[ $f == $g ]]; then tracked_bad+=" $f"; break; fi
    done
  done < <(git -C "$repo" ls-files)
  # makepkg 工作目录被跟踪
  for d in src pkg; do
    if [[ -n $(git -C "$repo" ls-files -- "$d" | head -1) ]]; then tracked_bad+=" $d/"; fi
  done
  if [[ -n $tracked_bad ]]; then
    for f in $tracked_bad; do bad "R5 构建产物已入库：$f"; done
  else
    ok 'R5 无构建产物入库'
  fi
else
  warn 'R5 不是 git 仓库，跳过入库检查'
fi

declare -A leak_locs=() ignored_locs=()
while IFS= read -r f; do
  rel=${f#"$repo"/}
  [[ $rel == files/* ]] && continue
  if [[ $rel == */* ]]; then loc=${rel%/*}; else loc=$rel; fi
  if ((in_git)) && git -C "$repo" check-ignore -q -- "$rel"; then
    ignored_locs[$loc]=1
  else
    leak_locs[$loc]=1
    bad "R5 产物未被忽略，有误提交风险：$rel"
  fi
done < <(
  find "$repo" \( -path '*/.git' -o -path '*/node_modules' \) -prune -o -type f \
       \( -name '*.pkg.tar.zst' -o -name '*.pkg.tar.zst.sig' -o -name '*.pkg.tar.xz' \
          -o -name '*.tar.xz' -o -name '*.tar.gz' -o -name '*.tar.bz2' -o -name '*.tar.zst' \
          -o -name '*.AppImage' -o -name '*.deb' -o -name '*.rpm' -o -name '*.o' \
          -o -name '*.so' -o -name '*.pyc' \) -print | sort
)
if ((${#leak_locs[@]} == 0 && ${#ignored_locs[@]} == 0)); then
  ok 'R5 工作区无构建产物'
elif ((${#ignored_locs[@]} > 0)); then
  warn "R5 工作区留有已忽略的产物（${!ignored_locs[*]}），建议移到仓库外；属整洁性问题，不阻塞"
fi

printf '\n-- 推荐项（不阻塞，按需补齐）\n'

# ---------------------------------------------------------------------------
# W1 CI 工作流
# ---------------------------------------------------------------------------
if compgen -G "$repo/.github/workflows/*.y*ml" >/dev/null; then
  ok 'W1 存在 CI 工作流'
else
  warn 'W1 无 .github/workflows/，改动无法自动验证'
fi

# ---------------------------------------------------------------------------
# W2 已验证环境小节
# ---------------------------------------------------------------------------
if [[ -s $readme ]] && grep -Eiq '^#{1,3} .*(已验证|环境要求|系统要求|依赖)' "$readme"; then
  ok 'W2 README 记录了环境要求或已验证环境'
else
  warn 'W2 README 未记录环境要求／已验证环境'
fi

# ---------------------------------------------------------------------------
# W3 tests/
# ---------------------------------------------------------------------------
if [[ -d $repo/tests ]] && compgen -G "$repo/tests/*" >/dev/null; then
  ok 'W3 存在 tests/'
else
  warn 'W3 无 tests/（不可测试的项目应在 README 说明原因）'
fi

# ---------------------------------------------------------------------------
# W4 一级目录在职责表内
# ---------------------------------------------------------------------------
known_dirs=" bin lib functions tools scripts templates packages files docs tests src pkg build "
unknown=""
while IFS= read -r d; do
  name=$(basename "$d")
  [[ $name == .git || $name == .github ]] && continue
  [[ $name == __pycache__ || $name == node_modules ]] && continue
  if [[ $known_dirs != *" $name "* ]]; then
    if ! grep -qF "$name/" "$readme" 2>/dev/null; then
      unknown+=" $name/"
    fi
  fi
done < <(find "$repo" -maxdepth 1 -mindepth 1 -type d ! -name '.*' | sort)
if [[ -z $unknown ]]; then
  ok 'W4 一级目录均在职责表内或已在 README 登记'
else
  warn "W4 目录未在职责表内且 README 未说明：$unknown"
fi

# ---------------------------------------------------------------------------
# W5 约定式提交
# ---------------------------------------------------------------------------
if ((in_git)); then
  total=0
  conform=0
  while IFS= read -r subj; do
    total=$((total + 1))
    [[ $subj =~ ^(feat|fix|docs|ci|chore|refactor|test|build|perf|style|revert)(\([^\)]+\))?!?:\ .+ ]] && conform=$((conform + 1))
  done < <(git -C "$repo" log -20 --pretty=%s 2>/dev/null)
  if ((total > 0 && conform == total)); then
    ok "W5 最近 $total 条提交均符合约定式提交"
  elif ((total > 0)); then
    warn "W5 最近 $total 条提交中 $((total - conform)) 条不符合约定式提交"
  fi
fi

printf '\n-- 结果：必需项 %s，推荐项 %s\n' \
  "$([[ $fails -eq 0 ]] && echo 全部通过 || echo "$fails 项未通过")" \
  "$([[ $warns -eq 0 ]] && echo 全部通过 || echo "$warns 项待补")"
((fails == 0)) && exit 0 || exit 1
