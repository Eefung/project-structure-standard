# 迁移清单

把 `docs/standard.md` 落到四个存量仓库。原则三条：

1. **一次一个仓库**：改完立刻跑该仓库 CI 与检查器，绿灯再动下一个。
2. **结构迁移独立提交**：挪文件、补许可证、改标题都单独成一次提交，别和内容修改混在一起，出问题能整段 revert。
3. **不为了规则改内容**：只补缺的骨架，不借机重写已有段落。

完成判据：四个仓库跑 `scripts/check-layout.sh <仓库>` 全部退出码 0，且 CI 通过。

## 进度

| 顺序 | 仓库 | 必改项 | 建议项 | 状态 |
|---|---|---|---|---|
| 1 | `tui-mode-recovery`（试点） | 无 | W2 补「已验证环境」 | 必需项已通过 |
| 2 | `obs-nvenc-legacy` | 无 | W3 说明为何无测试 | 必需项已通过 |
| 3 | `ffmpeg-nvenc-legacy` | 无 | 根目录产物移出；W3 说明 | 必需项已通过 |
| 4 | `magpie-repo` | R1、R2、R4 | W2、W5 例外登记 | 未开始 |

## 1. tui-mode-recovery（试点）

必需项已全绿，只提升可读性：

- 在 README 的「测试」小节后加 `### 已验证环境`，写清 CachyOS 内核版本、kitty 版本、fish 版本——这个项目的结论高度依赖终端与 shell 版本，不写环境等于不可复现。
- 不动 `install.sh --uninstall` 的现有设计：规范允许卸载做成参数（R3 只管「README 里写的命令能跑」）。

```sh
./scripts/check-layout.sh ~/Projects/tui-mode-recovery   # 期望 exit=0
```

## 2. obs-nvenc-legacy

- 无必改项。
- W3：这个仓库没有 `tests/`。要么给 `build.sh` 加一个 `--dry-run`（只打印检测到的驱动与头文件版本，不编译），用一条脚本断言这段输出；要么在 README 明确写「测试不适用，验证方式是 `--version` 与 OBS 日志」。后者成本更低，先做后者。

```sh
./scripts/check-layout.sh ~/Projects/obs-nvenc-legacy    # 期望 exit=0
```

## 3. ffmpeg-nvenc-legacy

- 无必改项（三个产物都已被 `.gitignore` 覆盖，`git ls-files` 里没有它们）。
- 建议：把根目录的 `ffmpeg-9.0.2.tar.xz`、`nv-codec-headers-13.0.19.1.tar.gz`、`ffmpeg-2:9.0.2-3.1-x86_64.pkg.tar.zst` 移出仓库根——源码包交给 `SRCDEST`，构建好的包挪到 `~/Packages` 一类目录。留着不会报错，只是 `ls` 会被淹没。

```sh
git -C ~/Projects/ffmpeg-nvenc-legacy ls-files | grep -E '\.(zst|xz|gz)$'   # 期望无输出
./scripts/check-layout.sh ~/Projects/ffmpeg-nvenc-legacy                    # 期望 exit=0，仅一条 tidiness 告警
```

## 4. magpie-repo

三处必需项，按顺序做：

1. **R1 补 `LICENSE`**：取 MIT 文本，版权行写 `Copyright (c) 2026 Eefung`（与另外两个 MIT 仓库一致；若打算保留私有，选 UNLICENSED 或换 GPL 需先定）。
2. **R4 挪交接文档**：`git mv HANDOFF.md docs/handoff.md`，保留历史；顺手把首行标题里的「HANDOFF」改成「交接」，与 `docs/` 下其余文档的中文标题一致。
3. **R2 补 README 三节**：
   - 「问题」：这个仓库为什么存在——上游每天发版、手动打包跟不上、装完要能 `pacman -Syu` 升级。
   - 「验证」：怎么确认一次发布成功——`pacman -Sy` 后能看到新版本、`repo-add` 的 db 条目、GitHub Release 与 Pages 站点一致。
   - 「许可」：指向 `LICENSE`。

建议项：W5 的 7 条 `upgpkg:` 提交来自 AUR 打包习惯，已在 `standard.md` 的例外登记里注明；W2 补一行上游版本与容器镜像版本。

```sh
./scripts/check-layout.sh ~/Projects/magpie-repo   # 期望 exit=0
gh workflow run publish.yml                        # 迁移后跑一次，确认发布链路没被打断
```

## 新仓库

复制模板，见 `templates/README.md`：

```sh
cp -r templates/script-project ~/Projects/<新仓库名>
# 替换 {{...}} 占位，git init，跑检查器
```
