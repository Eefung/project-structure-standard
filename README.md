# project-structure-standard

`~/Projects` 下的仓库越来越多，每个都合理，放在一起却不一致：入口脚本叫 `install.sh` / `build.sh` / `PKGBUILD`，卸载有独立脚本也有 `--uninstall` 参数，交接文档一个在根目录一个在 `docs/`，`magpie-repo` 甚至没有 `LICENSE`。项目少的时候靠记忆摊平，半年后再打开就只能重读 README。

这个仓库把这些靠记忆维持的一致性，变成可查、可检查的规则。

## 问题

项目少的时候，结构差异不痛；项目多、或者某个仓库半年没打开时，重新进入的成本只能靠结构摊平。目前四个仓库的共同顶层项只有 `.git`、`.gitignore`、`.github/`、`README.md`、`docs/`，其余靠各自习惯——`magpie-repo` 的 `HANDOFF.md` 在根目录而 `tui-mode-recovery` 的在 `docs/` 下；`magpie-repo` 没有 `LICENSE`；`ffmpeg-nvenc-legacy` 根目录躺着源码包与 `.pkg.tar.zst`。完整盘点见 [`docs/proposal.md`](docs/proposal.md)。

## 做法

把规范分三层，只有「能用几十行 shell 判定」的规则才进必需层：

| 文件 | 内容 |
|---|---|
| [`docs/standard.md`](docs/standard.md) | 规范正文：必需 5 条（R1–R5）、推荐 5 条（W1–W5）、目录职责表、写作与提交约定 |
| [`scripts/check-layout.sh`](scripts/check-layout.sh) | 检查器：对任一仓库运行，必需项缺失时退出码非 0 |
| [`tests/test-layout.sh`](tests/test-layout.sh) | 检查器自身的回归测试，用临时 fixture 覆盖每条必需规则 |
| [`docs/proposal.md`](docs/proposal.md) | 需求提案：现状盘点、目标、方法、交付物与验收标准 |

## 用法

```sh
# 检查任意仓库（默认当前目录）
scripts/check-layout.sh ~/Projects/tui-mode-recovery

# 只关心失败项
scripts/check-layout.sh --quiet .

# 退出码：0 必需项全过；1 有必需项未过；2 用法错误
```

## 验证

```sh
tests/test-layout.sh
```

测试用临时目录造 fixture：合规仓库应通过；删掉 `LICENSE`、去掉脚本执行位、README 代码块指向不存在的脚本、`docs/` 里放非 kebab-case 文件名、根目录放未忽略的产物、`HANDOFF.md` 放在根目录——每种都必须让检查器失败。

### 已验证环境

- CachyOS（Linux 7.3.3-1-cachyos），bash 5.x，GNU coreutils，git 2.x
- 对四个存量仓库实跑：`ffmpeg-nvenc-legacy`、`obs-nvenc-legacy` 通过；`tui-mode-recovery`、`magpie-repo` 按预期报出缺口
- `shellcheck -S warning` 无告警

## 许可

MIT，见 [`LICENSE`](LICENSE)。
