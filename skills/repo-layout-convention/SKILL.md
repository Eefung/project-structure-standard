---
name: repo-layout-convention
description: "Use when auditing or defining repo layout standards."
version: 3.1.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [repo-structure, conventions, readme, lint, shell]
    category: software-development
    related_skills: [project-docs, github]
---

# 项目结构规范

检查器判机械项（词与序），agent 判判断项（该不该有）。本文件是规范的唯一定义。

仓库 `github.com/Eefung/project-structure-standard`：本文件在 `skills/repo-layout-convention/`，检查器在 `scripts/check-layout.sh`——技能被复制到别处时也要有那个仓库。

## 何时用（When to Use）

- 判断仓库合不合规、统一多个自有仓库的结构。
- 写或迁移 README。
- 改规范本身：改词表、加一节。

## 机械项

```sh
scripts/check-layout.sh <仓库>      # 逐条打 ✓ / ✗
scripts/check-layout.sh -q <仓库>   # 只看不通过项
```

退出码：0 通过；1 有不通过项；2 用法错。检查器只读。

| # | 判定 | 不合规的样子 |
|---|---|---|
| 1 | 一级标题是自然语言项目名，下面有简介 | `# my-tool` |
| 2 | 二级标题只用词表里的词 | `## 工作原理`、`## Install`、`## Licence` |
| 3 | 出现的节按词表顺序递增、每节一次，`许可` 在最后 | `安装` 排在 `用法` 后；`许可` 后有 `致谢` |
| 4 | 标题语言与正文一致（正文汉字行 ≥20% 判中文） | 中文正文配 `## Usage` |
| 5 | `docs/` 下 `.md` 小写连字符；`handoff*.md` 若存在必须是 `docs/handoff.md` | `docs/Patch_Notes.md`、根目录 `HANDOFF.md` |
| 6 | 代码块里的 `*.sh`／`*PKGBUILD` 必须存在；根目录 `*.sh` 以命令出现需 `+x` | 代码块写 `./install.sh` 但无此文件 |
| 7 | 产物不入库、工作区产物被忽略；一级目录在词表内或在 README 登记 | `*.pkg.tar.zst` 入库；自造 `helper/` |

词表：`功能`或`原理`／`安装`／`用法`／`文档`／`许可`（英文 `Features`或`How it works`／`Installation`／`Usage`／`Documentation`／`License`）；可选 `开发`、`贡献`、`社区`、`致谢`（`Development`、`Contributing`、`Community`、`Acknowledgements`）。

首节与 `许可` 必填，中间四节可整节省略。一级目录词表：`bin lib functions tools scripts templates packages files docs tests skills src pkg build`。

## 判断项

- `LICENSE` 文件：公开仓库要有；`许可` 写「未授权，保留所有权利」也算合法。
- 某一节：没有安装过程就别写 `安装`，没有长文档就别写 `文档`、别为凑节建 `docs/`。
- `docs/`、`tests/`、CI：有就得真能跑，没有不是缺点。
- 词表外的新小节：能沉到 `docs/` 就沉；确有必要（如 `安全`）放行，位置在该节之后、`许可` 之前。

规范治「同一件事两种叫法」，不管「项目该有什么」。只有首节和 `许可` 的 README 合格，不为填结构编内容。

## 做法

- **判仓库**：`check-layout.sh -q <仓库>` 取机械项结果，再逐条过判断项。
- **改规范**：同一次提交改本文件与 `scripts/check-layout.sh`；无自动回归，改完在真实仓库上跑一遍。
- **起新仓库**：`cp -r templates/script-project ~/Projects/<名>`，替换 `{{...}}`，删用不到的节，`git init`，跑检查器。

## 写作与提交约定

- 各节不重复：`原理` 讲机制，`安装` 给命令与依赖，`文档` 只做索引。
- 只写执行所需：命令、判定、边界。不写教学式铺陈——读者是 agent 与维护者，不是新手。
- 安装不发明落地路径，用法不带 `cd`；已验证环境写在 `用法` 文末或 `docs/`。
- 中文正文全角标点，代码与 token 半角；时间戳写绝对时间。
- 提交 `type: 中文描述`，正文分条列点，末尾附验证环境行；初始提交用 `feat:`。

## 不要做的事

- 不加别名、不加「推荐」级、不把轻重写进规范。
- 不为让仓库变绿放松词表；不把规范扩到别的生态或要求协作文件。
