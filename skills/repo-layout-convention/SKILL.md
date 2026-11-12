---
name: repo-layout-convention
description: "Use when auditing or defining repo layout standards."
version: 3.9.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [repo-structure, conventions, readme, lint, shell]
    category: software-development
    related_skills: [project-docs, github]
---

# 项目结构规范

检查器判词与序，agent 判该不该有。本文件是唯一定义，位于 `github.com/Eefung/project-structure-standard/skills/repo-layout-convention/`；检查器在仓库 `scripts/check-layout.sh`。

## 原理

| # | 判定 |
|---|---|
| 1 | 一级标题自然语言项目名，下有简介 |
| 2 | 二级标题只用词表词 |
| 3 | 出现的节按词表顺序递增、每节一次，`许可` 最后 |
| 4 | 标题语言随正文（汉字行 ≥20% 判中文） |
| 5 | `docs/` 下 `.md` 小写连字符，`handoff*.md` 须为 `docs/handoff.md` |
| 6 | 代码块里的 `*.sh` 或 `*PKGBUILD` 须存在，根目录 `*.sh` 需 `+x` |
| 7 | 产物不入库且被忽略，一级目录在词表内或 README 登记 |

词表：首节用 `功能` 或 `原理`，随后 `安装`、`用法`、`问题`、`文档`、`参考`，`许可` 收尾；英文 `Features` 或 `How it works`，随后 `Installation`、`Usage`、`FAQ`、`Documentation`、`References`，`License` 收尾；可选 `开发`、`贡献`、`社区`、`致谢`（`Development`、`Contributing`、`Community`、`Acknowledgements`）。首节与 `许可` 必填，中间五节可省略。一级目录：`bin lib functions tools scripts templates packages files docs tests skills src pkg build`。

判断项（脚本不判）：`LICENSE` 公开仓库要有，`许可` 写「未授权」也可；某节、`docs/`、`tests/`、CI 没有不算缺点，有就得能跑；词表外小节能沉 `docs/` 就沉，确有必要就放行，放在该节后、`许可` 前。规范治两种叫法，不管项目该有什么。

## 用法

```sh
scripts/check-layout.sh <仓库>      # 0 通过、1 有不通过项、2 用法错
scripts/check-layout.sh -q <仓库>   # 只看 ✗
```

- 判仓库：`-q` 结果逐条过判断项。
- 写或迁移 README：按词表与顺序排节，用不到的节删掉。
- 改规则：同一次提交改本文件与 `scripts/check-layout.sh`，改完在真实仓库跑一遍。
- 起新仓库：`cp -r templates/script-project <新仓库>`，替换 `{{...}}`，`git init`，跑检查器。

## 约定

- 各节不重复：`原理` 讲机制，`安装` 给命令，`问题` 收问答，`文档` 做索引，`参考` 列材料。
- `问题` 每题三级标题，答案另起一段。
- `许可` 写「许可证名，见 [`LICENSE`](LICENSE)」。
- 只写执行所需，不写教学铺陈；安装不发明落地路径，用法不带 `cd`。
- 中文正文全角标点；提交 `type: 中文描述`，分条列点，末附验证环境行。
- 不加别名、不加「推荐」级、不放松词表、不扩到别的生态。
