#!/usr/bin/env bash
#
# check-layout.sh — 检查仓库是否满足项目结构规范的机械项
#
# 用法：
#   scripts/check-layout.sh [选项] [仓库路径]
#
# 选项：
#   -q, --quiet   只输出不通过项与汇总
#   -h, --help    显示本帮助
#
# 退出码：
#   0  机械项全部通过
#   1  有机械项不通过
#   2  用法错误
#
# 只判「词与序」这类永远适用的机械事实。要不要 LICENSE、要不要某一节、
# 要不要 docs/ 与测试，属于判断项，由 skills/repo-layout-convention/SKILL.md
# 判断，本脚本不置可否。

set -uo pipefail

QUIET=0
repo_arg=""
usage() { sed -n '3,19p' "$0" | sed 's/^# \{0,1\}//'; }

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

ok()     { ((QUIET)) || printf '  ✓ %s\n' "$*"; }
bad()    { fails=$((fails + 1)); printf '  ✗ %s\n' "$*"; }

# 标题归一：去首尾空白与末尾冒号，转小写，供逐字比对
norm() { printf '%s' "$1" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/[[:space:]]*[:：]$//' | tr '[:upper:]' '[:lower:]'; }

printf '== check-layout: %s\n' "$repo"

# ---------------------------------------------------------------------------
# 标题：一级标题形态与简介
# ---------------------------------------------------------------------------
readme=$repo/README.md
if [[ ! -s $readme ]]; then
  bad '标题 缺少 README.md'
else
  first=$(grep -m1 -vE '^[[:space:]]*$' "$readme" || true)
  if [[ $first =~ ^#[[:space:]]+(.+)$ ]]; then
    h1=${BASH_REMATCH[1]}
    h1=${h1%"${h1##*[![:space:]]}"}
    if [[ $h1 =~ ^[A-Za-z0-9]+([-_.][A-Za-z0-9]+)+$ ]]; then
      bad "标题 一级标题是仓库 slug（$h1），请写自然语言项目名"
    else
      ok '标题 一级标题是自然语言项目名'
    fi
  else
    bad '标题 首行不是一级标题（# 项目名）'
  fi

  overview=$(awk '/^#[[:space:]]/{h1=1;next} h1 && /^##[[:space:]]/{exit} h1{print}' "$readme" \
             | grep -c '[^[:space:]]' || true)
  if ((overview > 0)); then
    ok '标题 一级标题下有简介'
  else
    bad '标题 一级标题下没有简介文字（H1 与第一个二级标题之间）'
  fi
fi

# ---------------------------------------------------------------------------
# 标题：二级标题用词与顺序。许可必填，中间五节可整节省略；
#   出现的节按 功能/原理 → 安装 → 用法 → 问题 → 文档 → 参考 → 许可 递增，许可在最后。
# ---------------------------------------------------------------------------
if [[ -s $readme ]]; then
  cn_lines=$(grep -vE '^#{1,6}[[:space:]]' "$readme" | grep -cP '\p{Han}' || true)
  body_lines=$(grep -vE '^#{1,6}[[:space:]]' "$readme" | grep -c '[^[:space:]]' || true)
  if ((body_lines > 0 && cn_lines * 5 >= body_lines)); then
    res=('^(功能|原理)$' '^安装$' '^用法$' '^问题$' '^文档$' '^参考$' '^许可$')
    res_other=('^(features|how it works)$' '^installation$' '^usage$' '^faq$' '^documentation$' '^references$' '^license$')
    optional='^(开发|贡献|社区|致谢)$'
    vocab='功能、原理、安装、用法、问题、文档、参考、许可'
    optlist='开发、贡献、社区、致谢'
    hint='中文正文应配中文标题'
  else
    res=('^(features|how it works)$' '^installation$' '^usage$' '^faq$' '^documentation$' '^references$' '^license$')
    res_other=('^(功能|原理)$' '^安装$' '^用法$' '^问题$' '^文档$' '^参考$' '^许可$')
    optional='^(development|contributing|contributors|community|acknowledgements?)$'
    vocab='Features、How it works、Installation、Usage、FAQ、Documentation、References、License'
    optlist='Development、Contributing、Community、Acknowledgements'
    hint='英文正文应配英文标题'
  fi

  mapfile -t h2 < <(grep -E '^##[[:space:]]' "$readme" \
                    | sed -E 's/^##[[:space:]]+//; s/[[:space:]]+$//')

  prev=-1
  order_bad=0
  seen_license=0
  license_idx=-1
  unknown=""
  other_lang=""
  other_license=0
  for i in "${!h2[@]}"; do
    h=$(norm "${h2[$i]}")
    slot=""
    for s in 0 1 2 3 4 5 6; do
      # shellcheck disable=SC2053
      if [[ $h =~ ${res[$s]} ]]; then slot=$s; break; fi
    done
    if [[ -n $slot ]]; then
      ((slot <= prev)) && order_bad=1
      prev=$slot
      if ((slot == 6)); then
        seen_license=1
        license_idx=$i
      fi
      continue
    fi
    # shellcheck disable=SC2053
    if [[ $h =~ $optional ]]; then continue; fi

    in_other=0
    for s in 0 1 2 3 4 5 6; do
      # shellcheck disable=SC2053
      if [[ $h =~ ${res_other[$s]} ]]; then in_other=1; break; fi
    done
    if ((in_other)); then
      other_lang+="${h2[$i]}、"
      ((s == 6)) && other_license=1
    else
      unknown+="${h2[$i]}、"
    fi
  done

  if ((seen_license == 0)); then
    # 许可 写成了另一语言的词，语言不一致那条已经说明问题，不再重复报缺节
    ((other_license)) || bad "标题 缺少 许可 一节（词表：$vocab）"
  elif ((order_bad)); then
    bad '标题 二级标题顺序不对（应为 功能/原理 → 安装 → 用法 → 问题 → 文档 → 参考 → 许可，每节只出现一次）'
  elif ((license_idx != ${#h2[@]} - 1)); then
    bad "标题 许可 必须是最后一个二级标题，其后还有：${h2[$((license_idx + 1))]}"
  else
    ok '标题 二级标题用词与顺序合规'
  fi

  [[ -n $other_lang ]] && bad "标题 标题语言与正文不一致：${other_lang%、}（$hint）"
  [[ -n $unknown ]]    && bad "标题 规范外的二级标题：${unknown%、}（词表：$vocab；可选：$optlist）"
fi

# ---------------------------------------------------------------------------
# docs：文件名用词，以及交接文档位置
# ---------------------------------------------------------------------------
if [[ -d $repo/docs ]]; then
  bad_names=0
  while IFS= read -r f; do
    base=$(basename "$f")
    if ! [[ $base =~ ^[a-z0-9]+(-[a-z0-9]+)*\.md$ ]]; then
      bad "docs/$base 不是小写连字符（如 nvenc-runtime-negotiation.md）"
      bad_names=$((bad_names + 1))
    fi
  done < <(find "$repo/docs" -maxdepth 2 -name '*.md' -type f | sort)
  ((bad_names == 0)) && ok 'docs 文件名均为小写连字符'
else
  ok 'docs 无 docs/ 目录'
fi

# 交接文档位置与 docs/ 是否存在无关：根目录或 docs/ 里的 handoff*.md 都算
while IFS= read -r f; do
  rel=${f#"$repo"/}
  [[ $rel != docs/handoff.md ]] && bad "docs 交接文档位置不合规：$rel（应为 docs/handoff.md）"
done < <(find "$repo" -maxdepth 2 -iname 'handoff*.md' -not -path '*/.git/*' | sort)

# ---------------------------------------------------------------------------
# 入口：README 围栏代码块里的脚本必须真存在；根目录 *.sh 作为命令须可执行
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
      .*|*'*'*|*'{'*|/*) continue ;;   # 点开头、通配、模板占位、绝对路径不判定
    esac
    if [[ ! -e $repo/$tok ]]; then
      bad "入口 README 代码块里的 $tok 不存在"
      broken=$((broken + 1))
      continue
    fi
    entries=$((entries + 1))
    case "$tok" in
      bin/*|scripts/*|tools/*|tests/*) ;;   # 这些目录下的脚本不猜测调用方式
      */*) ;;
      *)
        if [[ $tok == *.sh && ! -x $repo/$tok ]]; then
          bad "入口 $tok 作为命令出现却不可执行（缺 chmod +x）"
        fi
        ;;
    esac
  done <<<"$tokens"
  if ((broken == 0 && entries > 0)); then
    ok "入口 README 代码块中的入口均存在（$entries 个）"
  fi
fi

# ---------------------------------------------------------------------------
# 产物：不得入库；工作区产物必须被忽略。files/ 是原样安装的载荷，豁免。
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
    for f in $tracked_bad; do bad "产物 已入库：$f"; done
  else
    ok '产物 无构建产物入库'
  fi
else
  bad '产物 不是 git 仓库，无法判定产物是否入库'
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
    bad "产物 未被忽略，有误提交风险：$rel"
  fi
done < <(
  find "$repo" \( -path '*/.git' -o -path '*/node_modules' \) -prune -o -type f \
       \( -name '*.pkg.tar.zst' -o -name '*.pkg.tar.zst.sig' -o -name '*.pkg.tar.xz' \
          -o -name '*.tar.xz' -o -name '*.tar.gz' -o -name '*.tar.bz2' -o -name '*.tar.zst' \
          -o -name '*.AppImage' -o -name '*.deb' -o -name '*.rpm' -o -name '*.o' \
          -o -name '*.so' -o -name '*.pyc' \) -print | sort
)
if ((${#leak_locs[@]} == 0 && ${#ignored_locs[@]} == 0)); then
  ok '产物 工作区无构建产物'
elif ((${#leak_locs[@]} == 0)); then
  ok "产物 工作区产物均已被忽略（${!ignored_locs[*]}）"
fi

# ---------------------------------------------------------------------------
# 目录：一级目录用既定词汇，新名字必须在 README 里以「名字/」登记
# ---------------------------------------------------------------------------
known_dirs=" bin lib functions tools scripts templates packages files docs tests skills src pkg build "
unknown_dirs=""
while IFS= read -r d; do
  name=$(basename "$d")
  [[ $name == __pycache__ || $name == node_modules ]] && continue
  if [[ $known_dirs != *" $name "* ]] && ! grep -qF "$name/" "$readme" 2>/dev/null; then
    unknown_dirs+=" $name/"
  fi
done < <(find "$repo" -maxdepth 1 -mindepth 1 -type d ! -name '.*' | sort)
if [[ -z $unknown_dirs ]]; then
  ok '目录 一级目录均在词表内或已在 README 登记'
else
  bad "目录 不在词表内且 README 未登记：$unknown_dirs"
fi

printf '\n-- 结果：%s\n' \
  "$([[ $fails -eq 0 ]] && echo 全部通过 || echo "$fails 项未通过")"
((fails == 0)) && exit 0 || exit 1
