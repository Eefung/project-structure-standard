# 项目结构规范

`~/Projects` 下的仓库各写各的：入口一个叫 `install.sh` 一个叫 `build.sh`，安装一节一个写 `安装` 一个写 `Installation`，交接文档一个在根目录一个在 `docs/`。这个仓库把这类不一致变成可查的东西——一个 shell 检查器管「词与序」这类机械项，一个技能管「这个项目该不该有这一节」这类判断项。

## 原理

检查器逐条比对机械项：标题用词、标题顺序、`docs/` 命名、README 代码块里的入口是否存在、构建产物有没有入库、一级目录名。每条打印 `✓` 或 `✗`，任一 `✗` 退出码 1。词表是封闭的——`安装` 的英文只认 `Installation`，写 `Install` 就是 `✗`。

「要不要 `LICENSE`」「没有安装过程的脚本要不要写 `安装` 一节」「要不要测试和 CI」不归脚本管。那是判断，写在技能的判断项里，由用规范的 agent 按项目性质现场定；所以一个只有标题和许可两节的最小 README 也能合格。

规范本体是 [`skills/repo-layout-convention/SKILL.md`](skills/repo-layout-convention/SKILL.md)，检查器是它机械项的实现。检查器只读，不写文件、不修东西。

## 安装

```sh
git clone https://github.com/Eefung/project-structure-standard.git
```

技能目录是 `skills/repo-layout-convention/`，检查器在同一仓库的 `scripts/check-layout.sh`。把技能目录放进你所用的 agent 的技能目录即可——Hermes 是 `~/.hermes/skills/`，Claude Code 是 `~/.claude/skills/`，Codex／Copilot／Gemini 一类还认跨 runtime 的 `~/.agents/skills/`：

```sh
cp -r skills/repo-layout-convention ~/.hermes/skills/
```

依赖：bash 4+、git、GNU coreutils。没有构建步骤。

判断项那半要 agent 支持加载技能（SKILL.md 那一套）才能用；不支持技能的 agent 只能跑检查器，机械项照样查得出。

## 用法

```sh
scripts/check-layout.sh ~/Projects/tui-mode-recovery   # 检查任意仓库
scripts/check-layout.sh -q .                           # 只看不通过项
```

退出码：0 全部通过；1 有不通过项；2 用法错误。

在 CachyOS（Linux 7.3.3-1-cachyos）、bash 5.x 上已验证，`shellcheck -S warning` 无告警。

## 开发

改这份规范本身时，用软链把技能挂到本机 agent 的技能目录，仓库里的文件改完即生效：

```sh
ln -sfn "$PWD/skills/repo-layout-convention" ~/.hermes/skills/repo-layout-convention
```

改词表或加一节，同一次提交改 `SKILL.md` 与 `scripts/check-layout.sh`，再到真实仓库上跑一遍检查器——这个仓库没有自动回归。

## 许可

MIT，见 [`LICENSE`](LICENSE)。
