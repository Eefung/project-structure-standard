# 项目结构规范

`~/Projects` 下的仓库每个都合理，放在一起却不一致：入口脚本叫 `install.sh` / `build.sh` / `PKGBUILD`，卸载有独立脚本也有 `--uninstall` 参数，交接文档一个在根目录一个在 `docs/`，`magpie-repo` 甚至没有 `LICENSE`。这个仓库（`project-structure-standard`）把靠记忆维持的一致性，变成可查、可检查的规则。

## 原理

规范是八条能用 shell 判定的结构事实：许可证在不在、README 六段齐不齐、文档命令能不能跑、目录名对不对、产物有没有入库、目录有没有登记、有没有 CI、有没有测试。检查器逐条比对仓库现状，每条打印 ✓ 或 ✗，任何一条 ✗ 就退出码 1——它只判合规与否，哪条先修是使用者的事。

检查器自己也有回归测试：每条规则配一个故意违规的临时仓库，规则放松或收紧都会让用例失败。规范、检查器、测试在同一次提交里改；CI 每次 push 跑回归测试、本仓库自查和两个模板自查，规范才不会在没人注意时漂移。

## 安装

```sh
git clone https://github.com/Eefung/project-structure-standard.git
```

依赖：bash 4+、git、GNU coreutils。没有构建步骤。

## 用法

```sh
cd project-structure-standard

# 检查任意仓库（不传路径则查当前目录）
scripts/check-layout.sh ~/Projects/tui-mode-recovery

# 只输出不合规项
scripts/check-layout.sh --quiet .

# 检查器自身的回归测试
tests/test-layout.sh
```

退出码：0 全部合规；1 有规则不合规；2 用法错误。

在 CachyOS（Linux 7.3.3-1-cachyos）、bash 5.x 上已验证，`shellcheck -S warning` 无告警；`tests/test-layout.sh` 27 个用例全过；本仓库与两个模板自查均 exit=0。

## 文档

- [`docs/standard.md`](docs/standard.md) — 八条规则：判定条件、为什么、违反后果
- [`docs/migration.md`](docs/migration.md) — 四个存量仓库逐条怎么改，含每个仓库的标题对照表
- [`docs/proposal.md`](docs/proposal.md) — 需求提案：现状盘点、目标、方法与验收标准
- [`templates/README.md`](templates/README.md) — 两个骨架给了什么、怎么复制

## 许可

MIT，见 [`LICENSE`](LICENSE)。
