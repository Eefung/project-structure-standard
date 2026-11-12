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

让本机 Hermes 读到仓库里的技能（软链，改技能就是改仓库）：

```sh
ln -sfn "$PWD/skills/repo-layout-convention" ~/.hermes/skills/repo-layout-convention
```

依赖：bash 4+、git、GNU coreutils。没有构建步骤。

## 用法

```sh
scripts/check-layout.sh ~/Projects/tui-mode-recovery   # 检查任意仓库
scripts/check-layout.sh -q .                           # 只看不通过项
```

退出码：0 全部通过；1 有不通过项；2 用法错误。

在 CachyOS（Linux 7.3.3-1-cachyos）、bash 5.x 上已验证，`shellcheck -S warning` 无告警。

## 许可

MIT，见 [`LICENSE`](LICENSE)。
