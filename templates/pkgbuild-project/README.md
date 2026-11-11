# {{包名}}

{{一句话：这个包解决什么问题，从哪装、装完看到什么。项目名用自然语言写，不要只写仓库 slug。}}

## 工作原理

`PKGBUILD` 从 {{上游来源，如 Arch 官方包}} 派生，只改 {{具体改了哪几处}}。入口是 `build.sh`，它只是把 `makepkg` 的参数透传下去。

| 文件 | 职责 |
|---|---|
| `PKGBUILD` | 打包定义；makepkg 要求它在仓库根 |
| `build.sh` | `makepkg -si` 的薄封装，统一入口 |
| `*.patch` | 对上游源码的补丁 |
| `docs/` | 长文档：原理、故障排查（出现时再建） |

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

打包逻辑集中在 `PKGBUILD` 的注释里；专题说明（原理、故障排查）出现时放 `docs/`，用 `docs/handoff.md` 交接。

## 许可

{{license}}，见 [LICENSE](LICENSE)。
