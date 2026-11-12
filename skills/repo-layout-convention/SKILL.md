---
name: repo-layout-convention
description: "Use when auditing or defining repo layout standards."
version: 3.2.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [repo-structure, conventions, readme, lint, shell]
    category: software-development
    related_skills: [project-docs, github]
---

# 项目结构规范

检查器判机械项，agent 判判断项。本文件是唯一定义，位于 `github.com/Eefung/project-structure-standard/skills/repo-layout-convention/`，检查器在仓库 `scripts/check-layout.sh`。

## 何时用（When to Use）

判断仓库合不合规；写或迁移 README；改规范本身。

## 机械项

```sh
scripts/check-layout.sh <仓库>      # ✓／✗ 逐条
scripts/check-layout.sh -q <仓库>   # 只看 ✗
```

退出码 0 通过／1 有不通过项／2 用法错。检查器只读。

| # | 判定 | 不合规 |
|---|---|---|
| 1 | 一级标题自然语言项目名，下有简介 | `# my-tool` |
| 2 | 二级标题只用词表词 | `## 工作原理`、`## Install` |
| 3 | 出现的节按词表顺序递增、每节一次，`许可` 最后 | `安装` 排在 `用法` 后 |
| 4 | 标题语言随正文（汉字行 ≥20% 判中文） | 中文正文配 `## Usage` |
| 5 | `docs/` 下 `.md` 小写连字符；`handoff*.md` 须为 `docs/handoff.md` | 根目录 `HANDOFF.md` |
| 6 | 代码块 `*.sh`／`*PKGBUILD` 须存在；根目录 `*.sh` 需 `+x` | 写 `./install.sh` 但无此文件 |
| 7 | 产物不入库且被忽略；一级目录在词表内或 README 登记 | `*.pkg.tar.zst` 入库；自造 `helper/` |

词表：`功能`|`原理`／`安装`／`用法`／`文档`／`许可`；英文 `Features`|`How it works`／`Installation`／`Usage`／`Documentation`／`License`；可选 `开发`／`贡献`／`社区`／`致谢`（`Development`／`Contributing`／`Community`／`Acknowledgements`）。

首节与 `许可` 必填，中间四节可省略。一级目录：`bin lib functions tools scripts templates packages files docs tests skills src pkg build`。

## 判断项

- `LICENSE`：公开仓库要有；`许可` 写「未授权」也可。
- 某一节：没有就省，别为凑结构建 `docs/`。
- `docs/`、`tests/`、CI：有就得能跑，没有不算缺点。
- 词表外小节：能沉 `docs/` 就沉；确有必要就放行，位置在该节后、`许可` 前。

规范治「同一件事两种叫法」，不管「项目该有什么」。

## 做法

- 判仓库：`-q` 结果逐条过判断项。
- 改规范：同一次提交改本文件与 `scripts/check-layout.sh`，改完在真实仓库跑一遍。
- 起新仓库：`cp -r templates/script-project <新仓库>`，替换 `{{...}}`，`git init`，跑检查器。

## 写作与提交约定

- 各节不重复：`原理` 讲机制，`安装` 给命令，`文档` 做索引。
- 只写执行所需，不写教学铺陈。
- 安装不发明落地路径，用法不带 `cd`；已验证环境写 `用法` 文末。
- 中文正文全角标点；提交 `type: 中文描述`，正文分条列点，末附验证环境行。

## 不要做的事

- 不加别名、不加「推荐」级、不把轻重写进规范。
- 不为变绿放松词表；不扩到别的生态或要求协作文件。
