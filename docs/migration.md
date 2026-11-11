# 迁移清单

把 `docs/standard.md` 落到四个存量仓库。原则三条：

1. **一次一个仓库**：改完立刻跑该仓库 CI 与检查器，绿灯再动下一个。
2. **结构迁移独立提交**：挪文件、补许可证、改标题都单独成一次提交，别和内容修改混在一起，出问题能整段 revert。
3. **只重组，不重写**：README 改成六段结构时，原有内容按语义搬到对应节里，措辞不动；确实写不清的段落才重写。

判据：四个仓库跑 `scripts/check-layout.sh <仓库>` 退出码 0，且 CI 通过。

## 进度

| 顺序 | 仓库 | 不合规项 | 状态 |
|---|---|---|---|
| 1 | `tui-mode-recovery`（试点） | R2 | 未开始 |
| 2 | `obs-nvenc-legacy` | R2、R8 | 未开始 |
| 3 | `ffmpeg-nvenc-legacy` | R2、R8 | 未开始 |
| 4 | `magpie-repo` | R1、R2、R4、R8 | 未开始 |

四个仓库的 R2 都是「重排」：信息块都在，只是标题用了中文各写各的，现在统一成固定词并固定顺序。旧标题 → 新节的对照见各仓库小节。四个仓库都是中文自述，标题一律用中文。

## 通用做法

```sh
# 1. 先看现状（贴成对照表，再动手）
grep -nE '^#{1,2} ' ~/Projects/<仓库>/README.md

# 2. 改完自查
~/Projects/project-structure-standard/scripts/check-layout.sh ~/Projects/<仓库>

# 3. 单独提交结构改动
git -C ~/Projects/<仓库> add -A
git -C ~/Projects/<仓库> commit -m 'docs: README 按六段结构重排'
```

`文档` 一节不是「文档内容」，是指向 `docs/` 的索引。原来塞在 README 里的长专题（原理、证据、排障）搬到 `docs/` 下，README 只留一行链接。

H1 要从 slug 换成中文名字——`tui-mode-recovery` → 「TUI 键盘恢复」、`obs-nvenc-legacy` → 「OBS NVENC 旧驱动修复」、`ffmpeg-nvenc-legacy` → 「FFmpeg NVENC 旧驱动」、`magpie-repo` → 「magpie 自托管源」。

## 1. tui-mode-recovery（试点）

| 旧标题 | 新节 |
|---|---|
| `# tui-mode-recovery` + 首段症状 | `# TUI 键盘恢复` + 简介（原首段保留） |
| `## 为什么这条命令有效`、`## 组件` | `## 原理`（两节合并，保留原顺序） |
| `## 快速开始` 的 `./install.sh` 部分、`## 安装与卸载` | `## 安装` |
| `## 快速开始` 的即时恢复命令、`## 使用`、`## 诊断` | `## 用法` |
| `## 测试`、`## 已知边界`、`## 参考` | 测试命令留在 `## 用法`；`已知边界`／`参考` 搬进 `docs/`，`## 文档` 里给链接 |
| `## License` | `## 许可` |

内核版本、kitty 版本、fish 版本写在 `## 用法` 文末一句话（不单开小节）。这个仓库已有 `tests/`、CI、`LICENSE`，R2 改完即合规。

```sh
./scripts/check-layout.sh ~/Projects/tui-mode-recovery   # 期望 exit=0
```

## 2. obs-nvenc-legacy

| 旧标题 | 新节 |
|---|---|
| `## 为什么会坏` | 首段简介的后半 + `## 原理` 开头 |
| `## 这个项目做什么`、`## 安装位置` | `## 原理` |
| `## 环境要求` | `## 安装` 开头一段 |
| `## 用法` | `## 安装` + `## 用法`（安装命令与日常命令分开） |
| `## 验证` | `## 用法` 文末（含「已验证环境」那段） |
| `## 注意事项` | 已有 `docs/troubleshooting.md`，`## 文档` 指过去 |
| `## 许可` | `## 许可` |

R8：新增 `tests/smoke.sh`，三条断言即可——`bash -n build.sh`、`build.sh --help` 退出码 0、`build.sh --help` 输出里含用法行。CI 已有 `lint.yml`，测试跑不跑是法官的事，但 `tests/` 必须存在且能手工跑。

```sh
./scripts/check-layout.sh ~/Projects/obs-nvenc-legacy    # 期望 exit=0
```

## 3. ffmpeg-nvenc-legacy

| 旧标题 | 新节 |
|---|---|
| `## 问题本质` | 首段简介 |
| `## 本项目的做法` | `## 原理` |
| `## 用法` 前半（装依赖、编译、装包） | `## 安装` |
| `## 用法` 后半 + 手动构建 | `## 用法` |
| `## 验证`（三项） | `## 用法` 文末 + `## 文档` 指向 `docs/` |
| `## 已验证环境` | 搬进 `docs/`，`## 文档` 给链接 |
| `## 维护须知` | `docs/handoff.md`（新写一份交接，原段落搬过去） |
| `## 致谢与许可` | `## 许可`（致谢保留在这一节末尾） |

R8：新增 `tests/smoke.sh`，断言 `bash -n install.sh`、`bash -n uninstall.sh`、`bash -c 'source PKGBUILD'` 三者通过。

根目录那三个源码包与 `.pkg.tar.zst` 都已被 `.gitignore` 覆盖，R5 合规，不必为规范挪动；想清清爽爽也可以移到仓库外，但那不是规范的要求。

```sh
./scripts/check-layout.sh ~/Projects/ffmpeg-nvenc-legacy   # 期望 exit=0
```

## 4. magpie-repo

| 旧标题 | 新节 |
|---|---|
| `## 用这个仓库装` | `## 安装`（含 `/etc/pacman.conf` 那段） |
| `## 每次运行做什么` | `## 原理` |
| `## 目录`、`## 发布到哪里` | `## 文档` 与 `## 原理` 的组件表 |
| `## 本机使用`、`## 注意事项` | `## 用法` |

其余三项：

1. **R1 补 `LICENSE`**：取 MIT 文本，版权行写 `Copyright (c) 2026 Eefung`（与另外两个 MIT 仓库一致）。
2. **R4 挪交接文档**：`git mv HANDOFF.md docs/handoff.md`，保留历史；首行标题里的「HANDOFF」改成「交接」。
3. **R8 新增 `tests/smoke.sh`**：断言 `python3 -m py_compile scripts/bump.py`、`bash -n scripts/*.sh`。

`## 许可` 新增一节指向 `LICENSE`。原来没有「问题」与「验证」两节：前者并入首段简介（上游每天发版、手动打包跟不上），后者写进 `## 用法`（`pacman -Sy` 后能看到新版本、`repo-add` 的 db 条目、Release 与 Pages 站点一致）。

CI 已有 `publish.yml`，满足 R7；发布链路是否重跑由法官决定。

```sh
gh workflow run publish.yml   # 迁移后跑一次，确认发布链路没被打断
```

## 新仓库

复制模板，见 `templates/README.md`：模板自带 CI 与 `tests/`，替换占位后应当直接合规。

```sh
cp -r templates/script-project ~/Projects/<新仓库名>
# 替换 {{...}} 占位，git init，跑检查器
```
