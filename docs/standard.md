# 项目结构规范

> 版本 v0.2 · 2026-11-11 · 配套检查器 `scripts/check-layout.sh`

本规范约束 `~/Projects` 下自有仓库的目录布局与元数据。规范只回答一个问题：**合不合规**。哪条先修、哪条暂时忍着，是用规范的人（下称法官）的决定，不写进规范。

## 0. 三分钟版

合规的仓库满足八条：`LICENSE` 非空；README 六段且标题精确；README 代码块里的命令真能跑；`docs/` 命名合规且交接文档在 `docs/handoff.md`；构建产物不入库且被忽略；一级目录在职责表内或 README 登记；有 CI 工作流；有 `tests/`。

自查：`scripts/check-layout.sh <仓库路径>`，退出码 0 即合规，非 0 即不合规。

## 1. 适用范围

适用：以 shell 脚本、Arch 打包、仓库与发布流程为主的自有仓库（当前四个：`ffmpeg-nvenc-legacy`、`magpie-repo`、`obs-nvenc-legacy`、`tui-mode-recovery`）。

不适用：由其他生态的包管理器定义布局的项目（`Cargo.toml`、`package.json`、`pyproject.toml` 的位置不由此规范决定）；对外协作的开源项目（本规范假设维护者是单人，不设 `CONTRIBUTING.md`、`CODE_OF_CONDUCT.md` 这类协作文件要求）。

## 2. 判定口径

- **只有两种结果**：合规、不合规。没有「推荐」「建议」「轻违规」，也没有「可接受的别名」。
- **规则必须能由脚本判定**：判不了的东西不写进规范，宁可缺一条，也不写一条靠自觉的规则。
- **精确匹配**：标题、文件名、目录名按规范列出的词逐字比对；同义词（`工作原理`）、拼写变体（`Licence`）、动词形（`Install`）都算不合规。
- **例外不是规范的一部分**：某条不合规但暂时不改，是法官的容忍，不是规范的许可；不需要在规范里登记。

## 3. 规则

### R1 根目录有非空的 `LICENSE`

- **为什么**：许可证决定别人（包括半年后的自己复用）能不能用、怎么用。GitHub 的 community profile 把 `LICENSE` 列为一类健康文件，缺了仓库页对外的信息就不完整。
- **违反后果**：使用边界只能靠口头记忆。`magpie-repo` 至今没有 `LICENSE`，它的打包脚本被别的仓库引用时无从判断条件。
- **判定**：`LICENSE` 存在且字节数大于 0。

### R2 README 六段结构

一级标题放**自然语言项目名**——写「项目结构规范」，不是 `project-structure-standard`；slug 可以出现在简介里。六段如下，标题语言随正文语言：

| 节 | 中文文档 | 英文文档 |
|---|---|---|
| 1 | `# 自然语言项目名` + 一段不带小标题的简介 | 同左 |
| 2 | `功能` 或 `原理` | `Features` 或 `How it works` |
| 3 | `安装` | `Installation` |
| 4 | `用法` | `Usage` |
| 5 | `文档` | `Documentation` |
| 6 | `许可` | `License`，必须是最后一节 |
| 可选 | `贡献` / `社区` | `Contributing` / `Community` |

- **判定**：解析 `^## ` 序列逐节精确匹配；顺序必须递增，许可一节必须是最后一节；首行必须是 `# `（且不是裸 slug），H1 与第一个 H2 之间必须有非空文字。
- **为什么不用 `Install`**：这一列标题都是名词（Features、Usage、Documentation、License），`Install` 是祈使动词，混在名词序列里不一致；它该出现的位置是命令本身。
- **为什么标题语言必须跟随正文**：中文正文配英文标题，读一句话要中途切换语码，跨仓库检索也按语言分裂。规则不是「英文更专业」，而是「一份文档只用一种标题语言」。检查器按正文汉字行占比（≥20%）判定语言，不匹配即不合规。
- **为什么顺序固定**：顺序固定后，检查器只需比对标题序列，不必猜语义；读者也总在同一位置找到同一类信息。
- **规范外的二级标题**（如 `故障排查`）不合规：内容沉到 `docs/`，由 `文档`／`Documentation` 指过去。

### R3 README 代码块里能照着跑的命令必须真的能跑

- **为什么**：README 的命令是读者最先复制的东西。命令失效是文档腐化最常见的形式，也是最容易自动发现的一种。
- **判定范围**：只看围栏代码块，正文里把别的仓库当例子提及不算（否则一份「规范文档」提一句 `install.sh` 就会被判违规）。通配（`*.sh`）、模板占位（`{{...}}`）、绝对路径不判定。
- **可执行位**：根目录下的 `*.sh` 必须 `chmod +x`。`lib/`、`functions/` 里被 source 的库不要求；`bin/`、`scripts/`、`tools/`、`tests/` 与多级路径不猜测调用方式。
- **违反后果**：读者复制命令 → `No such file`；或脚本存在但没有执行位 → `Permission denied`。
- **判定**：提取代码块中的 `*.sh` 与 `*PKGBUILD`，逐个 `test -e`。

### R4 `docs/` 命名与交接文档位置

- **命名**：`docs/`（含一级子目录）下的 `.md` 一律小写 kebab-case，正则 `^[a-z0-9]+(-[a-z0-9]+)*\.md$`。理由：大小写混用在 Linux 上不会报错，但检索、补全、按字母排序时分裂成两组。
- **交接文档**：仓库根与 `docs/` 两层内的任何 `handoff*.md` 必须是 `docs/handoff.md`（模板、示例目录里嵌套的不算——`templates/` 下自带一份骨架是正常的）。
- **为什么**：同类文档固定位置，才能用一条 `find` 找全所有仓库的当前状态；位置不固定时，「接手」只能靠记忆。
- **违反后果**：`magpie-repo` 的 `HANDOFF.md` 在根目录，`tui-mode-recovery` 的 `handoff.md` 在 `docs/` 下——同一类文档两种约定，跨仓库检索必然漏。
- **判定**：文件名正则 + `find -maxdepth 2 -iname 'handoff*.md'`。

### R5 构建产物不进 git，且工作区产物必须被忽略

- **产物**：`*.pkg.tar.*`、`*.tar.{xz,gz,bz2,zst}`、`*.AppImage`、`*.deb`、`*.rpm`、`*.o`、`*.so`、`*.pyc`，以及 makepkg 工作目录 `src/`、`pkg/`。
- **判定**：已入库（`git ls-files` 命中）→ 不合规；工作区存在但未被 `git check-ignore` 覆盖 → 不合规（下次 `git add .` 就会进去）；不是 git 仓库 → 不合规（无法判定）。
- **载荷目录**：`files/` 是原样安装到系统的载荷，允许放二进制（`obs-nvenc-legacy` 的 `files/reinstall.sh` 就是 pacman 钩子脚本），不按产物判定，但必须在 README 里登记职责（R6）。
- **为什么**：产物进 git 会让仓库体积单向上涨且不可逆；工作区产物未被忽略则是下一次误提交的伏笔。`ffmpeg-nvenc-legacy` 根目录的三个源码包与 `.pkg.tar.zst` 已被 `.gitignore` 覆盖，所以合规。
- **违反后果**：仓库膨胀、误提交、误删。

### R6 一级目录在职责表内，或在 README 登记过

- **为什么**：四个仓库已经用过十种一级目录名（`scripts`、`bin`、`lib`、`functions`、`tools`、`files`、`src`、`pkg`、`templates`、`packages`），再来一个同义词，检索与自动化就得再写一条规则。职责表把「新名字」这件事挡在门外。
- **判定**：一级目录必须在上表内，或该名字以 `名字/` 形式出现在 README 里（登记职责）。

### R7 有 CI 工作流

- **为什么**：规则如果只在本地跑，就只在想跑的时候跑；接进 CI 才是「每次都跑」。本仓库的 `.github/workflows/ci.yml` 同时跑检查器回归测试、本仓库自查与模板自查。
- **判定**：`.github/workflows/` 下至少一个 `.yml` 或 `.yaml`。

### R8 有 `tests/` 且非空

- **为什么**：可测的东西不写测试等于没有回归网；一次性脚本也至少能断言语法与 `--help` 输出。打包类项目的 `tests/smoke.sh` 可以断言 PKGBUILD 可解析、`source` 与 `sha256sums` 数量一致。
- **判定**：`tests/` 存在且非空。

## 4. 目录职责表

新目录只能从这张表里选；确实需要新名字时，先在 README 里写清职责（R6 以「在 README 出现」为判定）。

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

**根目录放什么**：`README.md`、`LICENSE`、`.gitignore`、`.github/`、`docs/`，加上该项目的入口（`install.sh`、`build.sh`、`PKGBUILD`、`src/`、`pkg/`）。补丁文件（`*.patch`）放根目录，与 `PKGBUILD` 保持一致。

**入口不强制同名**：打包类项目必须有根目录 `PKGBUILD`（makepkg 的硬性要求），脚本类项目用 `install.sh` 或 `build.sh` 都可。规范约束的不是名字统一，而是「名字在 README 的用法里写清楚、且真的存在」（R3）。

## 5. 写作约定（不做机器判定）

以下不是规则，是写法：它们不影响合规判定，但按它们写的东西读起来更省事。

- `docs/` 一个文件一个主题；专题文档不做「大杂烩」。
- 已验证环境写在 `用法` 的文末或 `docs/` 里，不单开小节。
- 交接文档按「当前状态 / 怎么做 / 未决事项 / 复现方法」组织。
- 中文正文用全角标点（，。；：、（）「」），代码与技术 token 内保持半角。
- 文档从零写：旧文档只当线索，每条说法先实测或读代码验证，再把结论写进去。
- 时间戳用绝对时间（`2026-11-11 15:20 CST`），不写「昨天」「上周」。

## 6. 提交约定（不做机器判定）

- 标题：`type: 中文描述`，type 取 `feat` / `fix` / `docs` / `ci` / `chore` / `refactor` / `test` / `build` / `perf` / `style` / `revert`；初始提交用 `feat:`。
- 正文分条列点，末尾附验证环境行（在哪台机器、什么系统、怎么验证的）。
- 一个提交一件事；结构迁移与内容修改分开提交，便于回溯。

## 7. 起手与迁移

- **新项目**：复制模板（`templates/`）→ 替换占位 → `git init` → 跑 `scripts/check-layout.sh .`，应当直接合规。
- **存量项目**：按 `docs/migration.md` 逐仓库处理，一次一个，改完立刻跑该仓库 CI 与检查器。

## 8. 修订

规则变更走提交记录，不靠口头约定。改动任何 R 规则时，同一次提交里更新 `scripts/check-layout.sh`、`tests/test-layout.sh` 与本文件，三者不一致即视为缺陷。
