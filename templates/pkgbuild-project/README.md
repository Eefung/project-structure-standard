# {{包名}}

{{一句话：这个包解决什么问题，从哪装、装完看到什么。项目名用自然语言写，不要只写仓库 slug。}}

## 原理

`PKGBUILD` 从 {{上游来源，如 Arch 官方包}} 派生，只改 {{具体改了哪几处}}。`build.sh` 只是 `makepkg -si` 的薄封装，参数原样透传。

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

## 许可

{{license}}，见 [LICENSE](LICENSE)。
