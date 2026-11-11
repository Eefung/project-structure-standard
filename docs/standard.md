# 项目结构规范

> 版本 v0.1（草案）· 2026-11-11 · 配套检查器 `scripts/check-layout.sh`

本规范约束 `~/Projects` 下自有仓库的目录布局与元数据。它只写「能被脚本判定」的规则，判定不了的写进推荐层或按需层，并说明理由——一条没人检查的「必须」等于没有。

## 0. 三分钟版

一个合规的仓库满足五件事：

1. 根目录有非空的 `LICENSE`。
2. `README.md` 是固定六段：`# 项目名` + 简介、`Features` 或 `How it works`、`Install` 或 `Installation`、`Usage`（或 `Quick start` / `Getting Started`）、`Documentation`、`License`；顺序不可乱，`License` 必须是最后一节。
3. README 代码块里出现的脚本路径真实存在，作为命令出现的 `.sh` 有可执行位。
4. `docs/` 里的文件名是小写 kebab-case，交接文档叫 `docs/handoff.md`。
5. 构建产物不进 git，工作区里的产物也必须在 `.gitignore` 覆盖范围内。

自查：`scripts/check-layout.sh <仓库路径>`，退出码 0 即合规。

## 1. 适用范围

适用：以 shell 脚本、Arch 打包、仓库与发布流程为主的自有仓库（当前四个：`ffmpeg-nvenc-legacy`、`magpie-repo`、`obs-nvenc-legacy`、`tui-mode-recovery`）。

不适用：由其他生态的包管理器定义布局的项目（`Cargo.toml`、`package.json`、`pyproject.toml` 的位置不由此规范决定）；对外协作的开源项目（本规范假设维护者是单人，不设 `CONTRIBUTING.md`、`CODE_OF_CONDUCT.md` 这类协作文件要求）。

## 2. 分层与判定口径

| 层 | 含义 | 违反时 |
|---|---|---|
| **必需** | 由 `check-layout.sh` 判定，规则编号 `R*` | 检查器退出码非 0，CI 红灯 |
| **推荐** | 由检查器告警，不阻塞 | 输出 `·` 提示，不阻塞合并 |
| **按需** | 用到了才管，规则写在目录职责表里 | 不检查 |

进入必需层的门槛：**规则能用几十行 shell 判定**。判定不了的（例如「README 是否写得清楚」）不进必需层，宁可缺一条也不要写一条靠自觉的规则。

## 3. 必需层

### R1 根目录有非空的 `LICENSE`

- **为什么**：许可证决定别人（包括半年后的自己换项目复用时）能不能用、怎么用。GitHub 的 community profile 直接把 `LICENSE` 列为一类健康文件，缺了仓库页对外的信息就不完整。
- **违反后果**：使用边界只能靠口头记忆。`magpie-repo` 至今没有 `LICENSE`，它的打包脚本被别的仓库引用时无从判断条件。
- **通过**：`LICENSE`（MIT、GPL 均可，按项目实际）。
- **检查**：文件存在且字节数大于 0。

### R2 README 六段结构

| 节 | 位置 | 内容 | 可用标题 |
|---|---|---|---|
| 1 | 首行 | 项目名 + 一段不带小标题的简介 | `# 项目名` |
| 2 | 第一个二级标题 | 功能清单，或它怎么做的 | `Features` / `How it works` |
| 3 | | 安装 | `Install` / `Installation` |
| 4 | | 用法 | `Usage` / `Quick start` / `Getting Started` |
| 5 | | 文档索引 | `Documentation` |
| 6 | 最后 | 许可 | `License` / `Licence` |
| 可选 | 5 与 6 之间 | 贡献、社区 | `Contributing` / `Community` |

- **标题用英文原文**（大小写不敏感，允许尾部冒号），正文语言不限——中文正文照旧写中文。
- **顺序固定，`License` 必须是最后一节。** 规范外的二级标题（如 `Troubleshooting`）只告警、不失败，但应当优先把内容沉到 `docs/`，由 `Documentation` 一节指过去。
- **为什么**：固定骨架让任何仓库都能用同一种方式读——先知道它是什么，再看怎么装、怎么用、文档在哪、能不能用。顺序固定还让检查器只需比对标题序列，不必猜语义；这比「关键词命中」可靠得多。
- **违反后果**：现状是四个仓库四套中文小标题（`问题本质`、`为什么会坏`、`这个项目做什么`……），跨仓库对照时每次都要重新找一遍位置。
- **检查**：解析 `^## ` 序列逐节匹配；首行必须是 `# `，H1 与第一个 H2 之间必须有非空文字。

### R3 README 代码块里能照着跑的命令必须真的能跑

- **为什么**：README 的命令是读者最先复制的东西。命令失效是文档腐化最常见的形式，也是最容易自动发现的一种。
- **判定范围**：只看围栏代码块（```），正文里把别的仓库当例子提及不算（否则一份「规范文档」提一句 `install.sh` 就会被判违规）。通配（`*.sh`）、模板占位（`{{...}}`）、绝对路径不判定。
- **可执行位**：只有「可能被当作命令直接执行」的路径要求 `chmod +x`——根目录下的 `*.sh`。`lib/`、`functions/` 里被 source 的库不要求；`bin/`、`scripts/`、`tools/`、`tests/` 与多级路径不猜测调用方式。
- **违反后果**：读者复制命令 → 报 `No such file`；或脚本存在但没有执行位 → `Permission denied`。
- **检查**：提取代码块中的 `*.sh` 与 `*PKGBUILD`，逐个 `test -e`。

### R4 `docs/` 命名与交接文档位置

- **命名**：`docs/`（含一级子目录）下的 `.md` 一律小写 kebab-case，正则 `^[a-z0-9]+(-[a-z0-9]+)*\.md$`。理由：大小写混用在 Linux 上不会报错，但检索、补全、按字母排序时分裂成两组。
- **交接文档**：仓库根与 `docs/` 两层内的任何 `handoff*.md` 必须是 `docs/handoff.md`（模板、示例目录里嵌套的不算——`templates/` 下自带一份骨架是正常的）。
- **为什么**：同类文档固定位置，才能用一条 `find` 找全所有仓库的当前状态；位置不固定时，「接手」这件事只能靠记忆。
- **违反后果**：`magpie-repo` 的 `HANDOFF.md` 在根目录，`tui-mode-recovery` 的 `handoff.md` 在 `docs/` 下——同一类文档两种约定，跨仓库检索必然漏。
- **检查**：文件名正则 + `find -iname 'handoff*.md'`。

### R5 构建产物不进 git，工作区产物必须被忽略

- **产物**：`*.pkg.tar.*`、`*.tar.{xz,gz,bz2,zst}`、`*.AppImage`、`*.deb`、`*.rpm`、`*.o`、`*.so`、`*.pyc`，以及 makepkg 工作目录 `src/`、`pkg/`。
- **判定**：已入库（`git ls-files` 命中）→ 失败；工作区存在但未被 `git check-ignore` 覆盖 → 失败（下次 `git add .` 就会进去）。
- **例外**：`files/` 是「原样安装到系统的载荷目录」，允许放二进制（`obs-nvenc-legacy` 的 `files/reinstall.sh` 就是 pacman 钩子脚本），不按产物判定，但必须在 README 里登记职责。
- **为什么**：产物进 git 会让仓库体积单向上涨且不可逆；产物留在根目录会让 `ls` 输出被淹没——`ffmpeg-nvenc-legacy` 根目录同时躺着源码包、头文件包和一个 `.pkg.tar.zst`，这些虽已被忽略、未入库，但仍在根目录里。
- **违反后果**：仓库膨胀、误提交、误删。
- **检查**：`git ls-files` + `git check-ignore`；工作区产物（已忽略）只告警，属整洁性问题，不阻塞。

## 4. 推荐层

| 编号 | 规则 | 为什么 |
|---|---|---|
| W1 | `.github/workflows/` 至少一个工作流 | 改动有机器验证，不靠记得跑 |
| W2 | README 正文或 `docs/` 里记录已验证环境 | 结论的可信度取决于环境是否写明；六段结构不给它单独小节，写在 `Usage` 文末或 `docs/` 即可 |
| W3 | 有 `tests/` 且非空 | 可测的项目不写测试，等于没有回归网；不可测的项目应在 README 说明原因 |
| W4 | 一级目录在「目录职责表」内，或已在 README 里登记 | 防止第十一种目录名诞生 |
| W5 | 最近 20 条提交符合约定式提交 | `git log --oneline` 可直接当变更历史读 |

## 5. 目录职责表

新目录只能从这张表里选；确实需要新名字时，先在 README 里写清职责，再进本表。

| 目录 | 职责 | 典型内容 |
|---|---|---|
| `bin/` | 给用户直接运行的可执行文件 | `tui-recover` |
| `lib/` | 被 source 的库代码 | `tui-recover.sh` |
| `functions/` | shell 函数定义（fish / zsh 装载） | `hermes.fish`、`tmr.fish` |
| `tools/` | 诊断与辅助脚本，不参与安装 | `kbdprobe.py` |
| `scripts/` | 仓库维护与发布脚本，CI 使用，不是最终用户入口 | `build-repo.sh`、`bump.py` |
| `templates/` | 生成用的模板 | `*.PKGBUILD.in` |
| `packages/` | 构建输入或产物清单：每个子目录一个包 | `packages/magpie-bin/` |
| `files/` | 原样安装到系统的载荷（允许二进制） | pacman 钩子脚本 |
| `docs/` | 长文档：专题说明、证据、故障排查、交接 | `docs/nvenc-runtime-negotiation.md` |
| `tests/` | 测试脚本 | `tests/test-byte-output.sh` |
| `src/`、`pkg/` | makepkg 工作目录，由工具生成 | 不入库 |
| `build/`、`build-*/` | 编译中间产物目录 | 不入库 |

**根目录放什么**：`README.md`、`LICENSE`、`.gitignore`、`.github/`、`docs/`，加上该项目的入口（`install.sh`、`build.sh`、`PKGBUILD`、`src/`、`pkg/`）。补丁文件（`*.patch`）可以放根目录或 `patches/`，与 `PKGBUILD` 保持一致。

**入口不强制同名**：打包类项目必须有根目录 `PKGBUILD`（makepkg 的硬性要求），脚本类项目用 `install.sh` 或 `build.sh` 都可。规范约束的不是名字统一，而是「名字在 README 的用法里写清楚、且真的存在」（R3）。

## 6. 文档与写作约定

- `docs/` 文件名：小写 kebab-case；一个文件一个主题；专题文档不做「大杂烩」。
- README 的二级标题只用规范列出的英文原文；正文语言不限。想加的内容优先沉到 `docs/`，由 `Documentation` 一节指过去，而不是给 README 再开一节。
- 已验证环境写在 `Usage` 的文末或 `docs/` 里，不单开小节。
- 交接文档固定为 `docs/handoff.md`，内容按「当前状态 / 怎么做 / 未决事项 / 复现方法」组织。
- 中文正文用全角标点（，。；：、（）「」），代码与技术 token 内保持半角。
- 文档从零写：旧文档只当线索，每条说法先实测或读代码验证，再把结论写进去。
- 时间戳用绝对时间（`2026-11-11 15:20 CST`），不写「昨天」「上周」。

## 7. 提交约定

- 标题：`type: 中文描述`，type 取 `feat` / `fix` / `docs` / `ci` / `chore` / `refactor` / `test` / `build` / `perf` / `style` / `revert`；初始提交用 `feat:`。
- 正文分条列点，末尾附验证环境行（在哪台机器、什么系统、怎么验证的）。
- 一个提交一件事；结构迁移与内容修改分开提交，便于回溯。

## 8. 起手与迁移

- **新项目**：复制模板（`templates/`，待补）→ 填 README 五段 → 加 `LICENSE` 与 `.gitignore` → 跑 `scripts/check-layout.sh .`。
- **存量项目**：按 `docs/migration.md`（待补）逐仓库处理，一次一个，改完立刻跑该仓库 CI 与检查器。

## 9. 例外登记

已知不满足必需项、且暂不整改的情况登记在此；每条都要有原因和复查时间。

| 仓库 | 规则 | 现状 | 原因 | 复查 |
|---|---|---|---|---|
| `magpie-repo` | W5 | 最近 20 条提交中 7 条为 `upgpkg:` 等非约定式标题 | AUR 打包习惯的自动提交 | 迁移时统一 |

## 10. 修订

规则变更走提交记录，不靠口头约定。改动必需层时，同一次提交里更新 `scripts/check-layout.sh` 与本文件，二者不一致即视为缺陷。
