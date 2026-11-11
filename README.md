# project-structure-standard

`~/Projects` 下的仓库越来越多，每个都合理，放在一起却不一致：入口脚本叫 `install.sh` / `build.sh` / `PKGBUILD`，卸载有独立脚本也有 `--uninstall` 参数，交接文档一个在根目录一个在 `docs/`，`magpie-repo` 甚至没有 `LICENSE`。项目少的时候靠记忆摊平，半年后再打开就只能重读 README。

这个仓库用来把这些靠记忆维持的一致性，变成可查、可检查的规则。

## 当前状态

提案阶段，尚未产出规范正文与检查脚本。

- 需求文档：[`docs/proposal.md`](docs/proposal.md)——盘点四个现有仓库的实测差异，给出目标、方法、交付物与验收标准。

## 计划产出

| 文件 | 内容 |
|---|---|
| `docs/standard.md` | 分层结构规范（必需 / 推荐 / 按需），每条附理由与反例 |
| `scripts/check-layout.sh` | 对任一仓库运行，必需项缺失时退出码非 0 |
| `templates/` | 脚本类与打包类项目骨架 |
| `docs/migration.md` | 逐仓库迁移清单 |

## 验证

验收标准见 `docs/proposal.md` 第 6 节；核心一条是：检查器在故意删掉 `LICENSE` 的仓库副本上必须报错。

## 许可

MIT，见 [`LICENSE`](LICENSE)。
