# 项目结构规范：面向个人多仓库工作台的目录约定与自动检查

**状态**：需求提案（待评审）
**日期**：2026-11-11
**范围**：`~/Projects` 下的自有仓库，当前 4 个（`ffmpeg-nvenc-legacy`、`magpie-repo`、`obs-nvenc-legacy`、`tui-mode-recovery`）

---

## 1. 引言

`~/Projects` 下现在有四个仓库，全部由同一人维护、全部托管在 `github.com/Eefung`，交付形态也高度相似：以 shell 脚本和 Arch 打包为核心，README 面向使用者，`docs/` 承载长文档。它们的共同点足以支撑一套统一规范，差异却足以让每次重新进入都付出额外成本。

这些差异目前不痛，因为项目少、且都还在记忆新鲜期内。但 `magpie-repo` 根目录那份 `HANDOFF.md` 已经说明了问题：写下它，是因为「下一个人（或下一次的我）」需要重新建立上下文。当仓库从 4 个变成 8 个、当某个仓库半年没有打开，重新进入的成本就不再靠记忆摊平，而只能靠结构摊平——入口在哪、边界在哪、当前状态在哪，应当是布局保证的，而不是每次翻 README 翻出来的。

本提案先盘点四个仓库的实际结构差异，把「靠记忆维持的一致性」变成可查、可检查的规则，再给出落地路径：分层规范、检查脚本、项目模板与逐仓库迁移清单。

## 2. 问题陈述

### 2.1 实测盘点

下表为 2026-11-11 对四个仓库工作区的直接观察结果（`ls` / `git ls-files` / 脚本内容），非估计。

| 仓库 | 入口脚本 | 卸载方式 | 文档 | LICENSE | 测试目录 | CI |
|---|---|---|---|---|---|---|
| `ffmpeg-nvenc-legacy` | `PKGBUILD` + `install.sh` | 独立 `uninstall.sh` | `docs/nvenc-runtime-negotiation.md` | GPL | 无 | `ci.yml` |
| `magpie-repo` | `scripts/`（打包脚本） | 无 | `docs/aur-setup.md`、`docs/pacman-repo.md`，另在**根目录**有 `HANDOFF.md` | **缺失** | 无 | `publish.yml` |
| `obs-nvenc-legacy` | `build.sh` | 独立 `uninstall.sh` | `docs/troubleshooting.md` | MIT | 无 | `lint.yml` |
| `tui-mode-recovery` | `install.sh`（带 `--uninstall`） | 同一脚本的参数 | `docs/evidence.md`、`docs/handoff.md` | MIT | `tests/`（3 个文件） | `ci.yml` |

四个仓库共同的顶层项只有：`.git`、`.gitignore`、`.github/`、`README.md`、`docs/`。除此之外，脚本目录用了 `scripts/`、`bin/`、`lib/`、`functions/`、`tools/`、`files/`、`src/`、`pkg/`、`templates/`、`packages/` 十种不同名字，彼此的职责边界没有任何文字定义。

### 2.2 具体问题

**P1 入口不统一，第一次打开必须读 README 才知道怎么跑。** 同样是「构建/安装」，四个仓库分别叫 `install.sh`、`build.sh`、`PKGBUILD`、`scripts/` 下的若干脚本；同样是「卸载」，两个用独立 `uninstall.sh`，一个用 `--uninstall` 参数，一个没有。这不是错误，但意味着任何自动化（批量检查、批量重建、跨仓库搜索）都必须为每个仓库单独写一条规则。

**P2 交接文档位置与命名漂移。** `magpie-repo` 的 `HANDOFF.md` 在根目录、全大写；`tui-mode-recovery` 的 `handoff.md` 在 `docs/` 下、小写。同一类文档，两种约定，检索时命不中。

**P3 元数据缺项不齐。** `magpie-repo` 没有 `LICENSE`（其余三个有，分别为 GPL 与 MIT，其中两个 MIT 文件 `md5` 完全一致）；只有 `tui-mode-recovery` 有 `tests/`；四个仓库都有 CI，但工作流分别是 `ci`、`lint`、`publish`，彼此没有最低共同要求。缺项不会报错，只会在需要时才发现——例如有人要复用 `magpie-repo` 的打包脚本时，才发现使用条件无处可查。

**P4 构建产物留在仓库根。** `ffmpeg-nvenc-legacy` 根目录存在 `ffmpeg-9.0.2.tar.xz`、`nv-codec-headers-13.0.19.1.tar.gz`、`ffmpeg-2:9.0.2-3.1-x86_64.pkg.tar.zst` 三个数百 MB 级文件，以及 `src/`、`pkg/` 两个 makepkg 工作目录。这些路径已被 `.gitignore` 覆盖（`git ls-files` 确认未入库），但物理上仍与源码、补丁、`PKGBUILD` 平铺在同一层：误删、误提交、以及 `ls` 输出被产物淹没的风险都在。

**P5 README 与 `docs/` 的分工没有规则。** 四个 README 长度 86–107 行，都在同一量级；`docs/` 内容却形态各异：专题技术说明、故障排查、实测证据、交接文档。什么该留在 README、什么该沉到 `docs/`、`docs/` 文件名用什么规范，全靠当时的判断。

**P6 已有约定散落在仓库之外。** 中文正文使用全角标点、提交遵循约定式提交并用中文描述、临时文件放 `~/.hermes/cache/scratch` 而不落在项目目录——这些已经在实际执行，但没有写进任何一个仓库，新仓库也无从继承。

### 2.3 需要回答的问题

1. 单人维护、以 shell 与打包为主的多仓库工作台，**最小可维护结构**是什么？
2. 哪些目录与文件属于「必需」，哪些属于「按需」？判定依据能否写成一句可检验的理由，而不是品味？
3. 现有四个仓库如何在**不破坏历史、不打断发布流程**的前提下迁移？
4. 规范如何被**持续执行**——检查脚本、CI、模板——而不是停在文档里？

## 3. 目标

**长期目标**：让「打开任意一个自有仓库，30 秒内知道入口、边界与当前状态」成为结构上的保证，而不是记忆的副产品。

**本次研究的具体目标**：

1. 产出一份分层目录规范（必需 / 推荐 / 按需），覆盖三种项目形态：脚本工具类、Arch 打包类、仓库/发布类。
2. 统一入口命名与 README 骨架（问题 → 做法 → 用法 → 验证 → 已验证环境 → 许可），与现有四份 README 的实际写法兼容。
3. 统一元数据：`LICENSE` 必需、`docs/` 文件名一律小写 kebab-case、交接类文档固定在 `docs/handoff.md`。
4. 定义构建产物与工作目录的落位规则，明确「仓库根只放源码与元数据」。
5. 提供可执行的检查器：对任一仓库运行，输出必需项缺失清单，缺失时退出码非 0，可直接接进 CI。
6. 提供项目模板与逐仓库迁移清单，使新项目从模板起手、旧项目按清单补齐。
7. 以 `tui-mode-recovery` 为试点完成迁移，验证规范与检查器，再推广到其余三个仓库。

## 4. 初步调研

### 4.1 可借鉴的既有规范

- **FHS 3.0**（Filesystem Hierarchy Standard）：按文件角色分目录（`/usr/bin`、`/etc`、`/var`），思路可直接借用于仓库内部——「角色决定位置」，而非「作者习惯决定位置」。但它约束的是系统安装后的落位，不约束仓库内部布局。
- **XDG Base Directory Specification**：约束用户态配置、缓存、数据的位置。对应到本项目群，就是安装脚本应当写到哪里（`~/.config/fish/functions`、`~/.local/bin`）以及临时产物不该落在哪（现有约定为 `~/.hermes/cache/scratch`）。可直接固化为「安装侧」规则。
- **Arch 打包规范**（Arch package guidelines / PKGBUILD）：已覆盖打包类项目的部分问题——`src/`、`pkg/` 是 makepkg 的固定工作目录，产物后缀固定为 `*.pkg.tar.zst`。它不管的是旁路脚本（`install.sh` / `uninstall.sh`）与文档，而这正是本规范要补的。
- **Conventional Commits、Keep a Changelog、SemVer**：提交与版本层面的既有事实标准。本项目群已在用约定式提交（中文描述），缺的是把它写进仓库。
- **REUSE / SPDX**：逐文件许可证标注。对单人项目偏重，列为可选层。
- **GitHub community health files**：README、LICENSE、CONTRIBUTING 等文件的默认识别位置，仓库缺 `LICENSE` 会直接影响仓库页对外的信息完整度——这是「LICENSE 必需」的直接依据，`magpie-repo` 正是反例。

### 4.2 既有规范的不足

上述规范都站在**单仓库内部**或**单文件**的视角：它们回答「这个文件该放哪」，不回答「同一个作者的一组仓库之间如何保持一致」。而本项目群的真实成本恰恰在后者——四个仓库各自都合理，放在一起却不一致。此外，既有规范大多是描述性的，没有给出「可以用几十行脚本检查的最小集合」。本规范要补的正是这两层：跨仓库的一致性，以及可自动执行的判定。

## 5. 方法

研究方法为**实测盘点 + 规范裁剪 + 工具验证 + 试点迁移**（case study）。一条规则只有在能被脚本判定时，才允许进入「必需」层；判定不了的，降级为「推荐」或「按需」，并写明理由。

| 阶段 | 内容 | 产出 |
|---|---|---|
| S1 基线 | 对四个仓库逐项跑清单，记录现状与例外 | 基线表（已具备雏形，见 2.1） |
| S2 起草 | 按必需 / 推荐 / 按需分层起草，每条附「为什么」与「违反后果」 | `docs/standard.md` 草案 |
| S3 工具 | 实现 `scripts/check-layout.sh` 与两个模板（脚本类、打包类） | 检查器、`templates/` |
| S4 试点 | 以 `tui-mode-recovery` 迁移，检验规范是否可执行、检查器是否误报 | 迁移后的试点仓库、问题清单 |
| S5 推广 | 其余三个仓库按清单迁移，检查器接入各仓库 CI | 四个仓库全绿、CI 片段 |

**时间表**（起点 2026-11-12，按周）：

| 周次 | 日期 | 里程碑 |
|---|---|---|
| W1 | 11-12 ~ 11-18 | 基线表定稿；`standard.md` 草案；规则可检查性逐条判定 |
| W2 | 11-19 ~ 11-25 | 检查器 + 模板完成；`tui-mode-recovery` 试点迁移通过 |
| W3 | 11-26 ~ 12-02 | 其余三个仓库迁移；检查器接入四个仓库 CI |
| W4 | 12-03 ~ 12-09 | 复跑检查、修订规范、定稿 v1.0 |

## 6. 交付物与验收

**交付物**

- `D1` `docs/standard.md`：分层规范正文，每条规则含判定条件、理由、反例。
- `D2` `scripts/check-layout.sh`：对任一仓库运行，列出必需项缺失；缺失时退出码非 0。
- `D3` `templates/`：`script-project/`、`pkgbuild-project/` 两个骨架。
- `D4` `docs/migration.md`：逐仓库迁移清单与已完成状态。
- `D5` CI 片段：把检查器接进 `.github/workflows/` 的最小工作流。

**验收标准**

- `A1` 对四个现有仓库运行检查器，必需项全部通过；确需保留的例外在 `standard.md` 中逐条登记并说明原因。
- `A2` 在故意删除 `LICENSE` 的仓库副本上运行检查器，返回非 0 并指名缺失项。
- `A3` 从模板新建一个项目，十分钟内通过检查器。
- `A4` `standard.md` 中每条「必需」规则都写明了「为什么」与「违反时会发生什么」，没有无理由的品味条款。
- `A5` 文档中不含未经实测的断言；涉及现状的数字与文件名均可复现。

## 7. 非目标与风险

**非目标**：不覆盖 Rust / Node / Python 生态各自的包管理约定（`Cargo.toml`、`package.json`、`pyproject.toml` 的位置由各生态决定）；不改仓库名；不改写历史提交；不引入重量级工具链（不做 monorepo 改造，不引入 Bazel / Nx 之类）；不改造 `magpie-repo` 的发布流程。

**风险与缓解**

- *规则过严，维护成本超过收益*：必需层保持最小（目标 6 条以内），其余进推荐层；每条必需规则都要能通过 `A2` 那样的反例测试证明它值得存在。
- *迁移打断 CI*：一次只迁一个仓库，迁完立即跑该仓库 CI，绿灯后再动下一个。
- *规范与实操漂移*：检查器进 CI 是唯一可持续的约束；规则变更必须走提交记录，不靠口头约定。

## 8. 参考文献

Arch Wiki. "Arch package guidelines." <https://wiki.archlinux.org/title/Arch_package_guidelines>

Conventional Commits. "Conventional Commits 1.0.0." <https://www.conventionalcommits.org/>

Free Standards Group. "Filesystem Hierarchy Standard 3.0." <https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html>

GitHub Docs. "About community profiles for public repositories." <https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/about-community-profiles-for-public-repositories>

Keep a Changelog. <https://keepachangelog.com/>

REUSE. "REUSE Specification." <https://reuse.software/spec/>

Semantic Versioning. "SemVer 2.0.0." <https://semver.org/>

XDG. "XDG Base Directory Specification." <https://specifications.freedesktop.org/basedir-spec/latest/>

University of Houston. "A Sample Research Proposal with Comments." <https://www.uh.edu/~lsong5/documents/A%20sample%20proposal%20with%20comment.pdf>
