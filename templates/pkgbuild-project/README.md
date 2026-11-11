# {{包名}}

{{一句话：这个包解决什么问题，从哪装、装完看到什么。项目名用自然语言写，不要只写仓库 slug。}}

## 原理

`PKGBUILD` 从 {{上游来源，如 Arch 官方包}} 派生，只改 {{具体改了哪几处}}。`build.sh` 只是 `makepkg -si` 的薄封装，参数原样透传；`tests/smoke.sh` 断言 PKGBUILD 能被 bash 解析、`pkgname` / `pkgver` / `arch` / `license` 齐全、`source` 与 `sha256sums` 数量一致。

| 文件 | 职责 |
|---|---|
| `PKGBUILD` | 打包定义；makepkg 要求它在仓库根 |
| `build.sh` | `makepkg -si` 的薄封装，统一入口 |
| `*.patch` | 对上游源码的补丁 |

## 安装

```sh
./build.sh
```

构建并安装，会要一次 sudo 授权。热编译用 `./build.sh --force`。

## 用法

```sh
./build.sh --force         # 强制重新编译
makepkg -sc                # 清掉工作目录与已下载源码
pacman -Qi {{包名}}        # 确认装的是本仓库的包
```

在 {{发行版与内核}}、{{上游版本与依赖版本}} 上已验证。

## 文档

暂无独立文档：打包逻辑写在 `PKGBUILD` 的注释里。出现原理说明或故障排查时放 `docs/`，交接文档写到 `docs/handoff.md`（出现时新建）。

## 许可

{{license}}，见 [LICENSE](LICENSE)。
