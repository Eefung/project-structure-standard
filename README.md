# 项目结构规范

`~/Projects` 下的仓库各写各的：安装一节一个写 `安装` 一个写 `Installation`，交接文档一个在根目录一个在 `docs/`。这个仓库把这类不一致变成可查的：检查器判机械项，技能判判断项。规范本体是 [`skills/repo-layout-convention/SKILL.md`](skills/repo-layout-convention/SKILL.md)。

## 原理

检查器比对七项机械事实：一级标题形态、二级标题用词与顺序、标题语言、`docs/` 命名与交接文档位置、代码块入口是否存在、构建产物是否入库、一级目录名。每条 `✓`／`✗`，任一 `✗` 退出码 1。词表封闭，`Install` 不是 `Installation` 的别名。

要不要 `LICENSE`、要不要某一节、要不要 `docs/` 与测试，归技能判断，脚本不管。

## 安装

```sh
git clone https://github.com/Eefung/project-structure-standard.git
cp -r skills/repo-layout-convention ~/.hermes/skills/
```

技能目录的落点随 agent 变：Hermes `~/.hermes/skills/`，Claude Code `~/.claude/skills/`，Codex／Copilot／Gemini 还认 `~/.agents/skills/`。依赖：bash 4+、git、GNU coreutils。

## 用法

```sh
scripts/check-layout.sh ~/Projects/<仓库>
scripts/check-layout.sh -q .
```

退出码：0 全部通过；1 有不通过项；2 用法错误。在 CachyOS（Linux 7.3.3-1-cachyos）、bash 5.x 上验证，`shellcheck -S warning` 无告警。

## 开发

```sh
ln -sfn "$PWD/skills/repo-layout-convention" ~/.hermes/skills/repo-layout-convention
```

改词表或加一节，同一次提交改 `SKILL.md` 与 `scripts/check-layout.sh`；无自动回归，改完在真实仓库上跑一遍。

## 许可

MIT，见 [`LICENSE`](LICENSE)。
