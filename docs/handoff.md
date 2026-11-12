# 交接 — 项目结构规范

写作时间 2026-11-12 14:10 CST。给下一个人（或下一次的我）：读完这一页应当能接手，不必翻提交历史。文中每个数字都是实测的，复现方法见最后一节。

## 当前状态

| 项 | 值 |
|---|---|
| 仓库 | `github.com/Eefung/project-structure-standard`（public，默认分支 `main`） |
| 本地 HEAD | `e7b6584`（`docs: 新增交接文档`，即本文件所在提交） |
| 规则 | 8 条，`R1`–`R8`，见 `docs/standard.md` |
| 检查器 | `scripts/check-layout.sh`：只有 `✓`／`✗`，任一 `✗` 退出码 1，不判轻重 |
| 回归测试 | `tests/test-layout.sh`：27 个用例，全过 |
| 本仓库 | 自查 exit=0（8 条全过） |
| 模板 | `script-project`、`pkgbuild-project` 复制并 `git init` 后各自 exit=0 |
| CI | GitHub Actions 最近三次均 success：`43053716525`（`583026c`）、`43051543377`、`43048505426` |

四个存量仓库状态（2026-11-12 14:10 实测，全部 exit=1）：

| 仓库 | 不合规项 |
|---|---|
| `tui-mode-recovery` | R2：H1 是 slug、缺 `原理`／`安装`／`文档`／`许可`、十个规范外二级标题 |
| `obs-nvenc-legacy` | R2：缺 `原理`／`安装`／`文档`；R8：无 `tests/` |
| `ffmpeg-nvenc-legacy` | R2：缺 `原理`／`安装`／`文档`／`许可`；R8：无 `tests/` |
| `magpie-repo` | R1：无 `LICENSE`；R2 同上；R4：`HANDOFF.md` 不在 `docs/`；R8：无 `tests/` |

## 怎么做

- **判定一个仓库**：`scripts/check-layout.sh <路径>`，`-q` 只看失败项。它不写文件、不修东西，只报结果。
- **改规则**：`docs/standard.md`、`scripts/check-layout.sh`、`tests/test-layout.sh` 必须在同一次提交里改；三者不一致视为缺陷。
- **加一条规则的顺序**：先在 `standard.md` 写判定条件、为什么、违反后果 → 在检查器里加一段 → 在 `tests/test-layout.sh` 造一个违规 fixture 并断言退出码与提示 → 跑 `tests/test-layout.sh`。
- **新仓库**：从 `templates/` 复制骨架（见 `templates/README.md`），模板自带 CI 与 `tests/`，替换占位后应当直接合规。
- **迁移存量仓库**：按 `docs/migration.md` 一次一个，改完立刻跑该仓库 CI 与检查器；README 重排时只搬内容、不重写。

## 未决事项

- **四个存量仓库都未迁移**。`tui-mode-recovery` 是试点，只差 R2（改标题、H1 换成中文名）；其余三个还要补 `tests/smoke.sh`，`magpie-repo` 另需 `LICENSE` 与 `git mv HANDOFF.md docs/handoff.md`。
- **R7（CI）、R8（tests）是规范作者自己加的规则**，尚未确认是否要算「法」。若否掉：删掉检查器里对应两段、删掉两个 fixture 用例、删掉 `standard.md` 的 R7／R8 与三分钟版里的相应条目，规则回到 6 条。
- **CI 每次 `apt-get install shellcheck`**，一次 run 约 6 分钟（`43048505426` 从 queued 到 success）。GitHub 的 ubuntu 镜像可能已预装，可改成 `command -v shellcheck || sudo apt-get install …`，未做。
- **规范外二级标题按「不合规」处理**。若将来允许 `贡献`／`社区` 之外的小节，需同时改检查器的 `optional` 正则与 `standard.md` 的 R2 表格。
- **`docs/proposal.md` 的验收项 `A3`（十分钟内从模板起手）没有真实计时**，只在模板复制用例里验证过「能合规」。

## 复现方法

```sh
# 1. 拿到仓库
git clone https://github.com/Eefung/project-structure-standard.git

# 2. 在克隆出的目录里：本仓库自查
scripts/check-layout.sh .
# 期望：11 行 ✓，末行「-- 结果：全部通过」，exit 0

# 3. 检查器自身的回归测试
tests/test-layout.sh
# 期望：「== 结果：27 通过，0 失败」，exit 0

# 4. 验证某条规则真的会拦：拿模板副本删掉 LICENSE
tmp=$(mktemp -d)
cp -r templates/script-project "$tmp/p"
git -C "$tmp/p" init -q
git -C "$tmp/p" add -A
git -C "$tmp/p" -c user.name=t -c user.email=t@example.com commit -qm 'feat: 从模板起手'
rm "$tmp/p/LICENSE"
scripts/check-layout.sh "$tmp/p"
# 期望：✗ R1 缺少 LICENSE，exit 1

# 5. 看四个存量仓库的现状（均 exit 1）
for p in tui-mode-recovery obs-nvenc-legacy ffmpeg-nvenc-legacy magpie-repo; do
  scripts/check-layout.sh -q ~/Projects/"$p"
done

# 6. 远端 CI 状态
gh run list --limit 3
```
