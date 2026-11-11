# 项目结构规范

`~/Projects` 下的仓库每个都合理，放在一起却不一致：入口脚本叫 `install.sh` / `build.sh` / `PKGBUILD`，卸载有独立脚本也有 `--uninstall` 参数，交接文档一个在根目录一个在 `docs/`，`magpie-repo` 甚至没有 `LICENSE`。这个仓库（`project-structure-standard`）把靠记忆维持的一致性，变成可查、可检查的规则。

## 工作原理

规范分三层，只有「能用几十行 shell 判定」的规则才进必需层；每条必需规则都有对应的检查代码和一个 fixture 反例。

| 文件 | 内容 |
|---|---|
| [`docs/standard.md`](docs/standard.md) | 规范正文：必需 5 条（R1–R5）、推荐 5 条（W1–W5）、目录职责表、写作与提交约定 |
| [`scripts/check-layout.sh`](scripts/check-layout.sh) | 检查器：对任一仓库运行，必需项缺失时退出码 1 |
| [`tests/test-layout.sh`](tests/test-layout.sh) | 检查器自身的回归测试，用临时 fixture 覆盖每条必需规则 |
| [`templates/`](templates/README.md) | 两个骨架：`script-project/`（脚本工具）、`pkgbuild-project/`（Arch 打包） |
| [`docs/migration.md`](docs/migration.md) | 逐仓库迁移清单与进度 |
| [`docs/proposal.md`](docs/proposal.md) | 需求提案：现状盘点、目标、方法、交付物与验收标准 |

## 安装

```sh
git clone https://github.com/Eefung/project-structure-standard.git ~/Projects/project-structure-standard
```

无依赖：bash 4+、git、GNU coreutils。没有安装步骤，克隆完直接跑检查器。

## 用法

```sh
# 检查任意仓库（默认当前目录）
scripts/check-layout.sh ~/Projects/tui-mode-recovery

# 只关心失败项
scripts/check-layout.sh --quiet .

# 检查器自身的回归测试
tests/test-layout.sh
```

退出码：0 必需项全过；1 有必需项未过；2 用法错误。`✓` 通过、`·` 推荐项告警、`✗` 必需项失败。

在 CachyOS（Linux 7.3.3-1-cachyos）、bash 5.x 上已验证，`shellcheck -S warning` 无告警；`tests/test-layout.sh` 21 个用例全过。

## 文档

- [`docs/standard.md`](docs/standard.md) — 规则正文：判定条件、为什么、违反后果
- [`docs/migration.md`](docs/migration.md) — 四个存量仓库怎么改，逐仓库命令与预期输出
- [`templates/README.md`](templates/README.md) — 新仓库从哪个骨架起手
- [`docs/proposal.md`](docs/proposal.md) — 需求提案与验收标准

## 许可

MIT，见 [`LICENSE`](LICENSE)。
