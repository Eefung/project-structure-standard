---
name: repo-layout-convention
description: "Use when auditing or defining repo layout standards."
version: 3.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [repo-structure, conventions, readme, lint, shell]
    category: software-development
    related_skills: [project-docs, github]
---

# 项目结构规范

自有仓库之间的一致性靠两样东西：一个 shell 检查器管机械项（词与序），一个 agent 管判断项（该不该有）。本文件是规范的唯一定义；检查器是它的机械项实现。

仓库：`~/Projects/project-structure-standard`（`github.com/Eefung/project-structure-standard`），本文件位于该仓库 `skills/repo-layout-convention/`。检查器在同一仓库的 `scripts/check-layout.sh`——技能被复制到别的机器时，也要有那个仓库才能跑机械项，没有就先 clone。

## 何时用（When to Use）

- 判断某个仓库合不合规，或给多个自有仓库统一结构。
- 写新仓库的 README，或迁移旧仓库的 README。
- 改这条规范本身：改词表、加一节、改检查器。

## 机械项：检查器判

```sh
scripts/check-layout.sh ~/Projects/<仓库>     # 逐条打 ✓ / ✗
scripts/check-layout.sh -q .                  # 只看不通过项
```

退出码：0 全部通过；1 有不通过项；2 用法错。检查器只读，不写文件、不修东西。

| # | 判定 | 不合规的样子 |
|---|---|---|
| 1 | 一级标题写自然语言项目名，下面有简介正文 | `# my-tool`（仓库 slug） |
| 2 | 二级标题只用词表里的词（见下），可选白名单另计 | `## 工作原理`、`## 快速开始`、`## Install`、`## Licence` |
| 3 | 出现的节按词表顺序递增，每节只出现一次；`许可` 必须是最后一个二级标题 | `安装` 排在 `用法` 后面；`许可` 之后还有 `致谢` |
| 4 | 标题语言与正文语言一致（正文汉字行 ≥20% 判中文） | 中文正文配 `## Usage` |
| 5 | `docs/` 下 `.md` 小写连字符；`handoff*.md` 若存在必须是 `docs/handoff.md` | `docs/Patch_Notes.md`、根目录 `HANDOFF.md` |
| 6 | README 代码块里的 `*.sh`／`*PKGBUILD` 必须真存在；根目录 `*.sh` 以命令出现时要有 `+x` | 代码块写 `./install.sh` 但文件不存在 |
| 7 | 构建产物不入库；工作区产物必须被忽略；一级目录名在词表内或在 README 登记 | `pkg.tar.zst` 提交进 git；自造 `helper/` 目录 |

词表（逐字比对，不接同义词、不接拼写变体）：

| 节 | 中文正文 | 英文正文 |
|---|---|---|
| 1 | `# 自然语言项目名` + 简介 | 同左 |
| 2 | `功能` 或 `原理` | `Features` 或 `How it works` |
| 3 | `安装` | `Installation` |
| 4 | `用法` | `Usage` |
| 5 | `文档` | `Documentation` |
| 6 | `许可`（必填，且必须是最后一节） | `License` |
| 可选 | `贡献`、`社区`、`致谢` | `Contributing`、`Community`、`Acknowledgements` |

一级目录词表：`bin lib functions tools scripts templates packages files docs tests skills src pkg build`。根目录放 `README.md`、`LICENSE`、`.gitignore`、`.github/`、`docs/`，加上项目入口。

**中间四节可以整节省略。** 只有第一节和 `许可` 是必填，其余按项目实际需要出现。

## 判断项：agent 判

检查器对这些不说话，由你按项目性质定：

- **要不要 `LICENSE` 文件。** 公开或要给别人用的仓库要有；`许可` 一节写「未授权，保留所有权利」也算合法。
- **要不要某一节。** 简单脚本没有安装过程就别写 `安装`；没有长文档就别写 `文档`，也别为了凑节新建 `docs/`。
- **要不要 `docs/`、`tests/`、CI。** 有就得真能跑；没有不是缺点。
- **词表外的新小节。** 先想能不能沉到 `docs/`；确有必要（如 `安全`、`数据来源`）就放行，位置放在它所解释的那一节之后、`许可` 之前，并且在 README 里说清它不是规范词汇。

判断原则：**规范治的是「同一件事两种叫法」，不是「项目该有什么」。** 一个只有一节和许可的最小 README 是合格的；不要为了填满结构去编内容。

## 做法

**判一个仓库**：`scripts/check-layout.sh -q <仓库>` 拿机械项结果，再逐条想判断项——缺的节是真不需要，还是漏了；有的节措辞对不对。

**改规范**：改词表或加一节时，同一次提交改两处——`skills/repo-layout-convention/SKILL.md` 与 `scripts/check-layout.sh`；两处不一致即视为缺陷。改完在真实仓库上跑一遍检查器（这个仓库没有自动回归）。

**从模板起手**：`cp -r ~/Projects/project-structure-standard/templates/script-project ~/Projects/<新仓库>`，替换 `{{...}}` 占位，删掉用不到的节，`git init`，再跑检查器。两个模板分别是装到 `~/.local/bin` 的小工具与 Arch 打包项目。

## 写作与提交约定

- 各节不重复：`原理` 只讲机制，`安装` 只给命令与依赖，`文档` 只做 `docs/` 的索引。
- 安装不发明落地路径：`git clone <url>` 就够。
- 用法不带 `cd`：命令默认在仓库根执行。
- 已验证环境写在 `用法` 文末或 `docs/`，不单开小节。
- 中文正文用全角标点（，。；：、（）「」），代码与技术 token 内保持半角。
- 时间戳写绝对时间（`2026-11-12 14:10 CST`）。
- 提交：`type: 中文描述`，正文分条列点，末尾附验证环境行；初始提交用 `feat:`。

## 不要做的事

- 不加别名、不加「推荐」级、不把轻重写进规范——轻重是使用者的事。
- 不为让某个仓库变绿而放松词表；要么改仓库，要么承认它暂时不合规。
- 不把规范扩到别的生态（`package.json`、`Cargo.toml`、`pyproject.toml` 决定布局的项目），也不要求 `CONTRIBUTING.md` 这类协作文件——本规范假设维护者是单人。
