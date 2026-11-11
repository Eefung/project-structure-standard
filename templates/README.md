# 模板

两个骨架，各对应一种项目形态。用法是复制，不是 submodule：

```sh
cp -r templates/script-project ~/Projects/<新仓库名>
cd ~/Projects/<新仓库名>
# 把 {{...}} 占位全部替换掉，再 git init
```

复制完在仓库根跑一次检查器，必需项应当直接全绿：

```sh
~/Projects/project-structure-standard/scripts/check-layout.sh .
```

| 模板 | 形态 | 入口 | 何时用 |
|---|---|---|---|
| `script-project/` | 脚本工具 | `install.sh`（含 `--check` / `--uninstall`） | 装到 `~/.local/bin` 的小工具、shell 包装 |
| `pkgbuild-project/` | Arch 打包 | `build.sh` → `makepkg -si` | 从上游源码或二进制打 pacman 包 |

## script-project 给了什么

- `install.sh`：装到 `~/.local/bin`（尊重 `XDG_BIN_HOME`），重复执行安全，`--check` 比较已装副本、`--uninstall` 只删自己装的文件。
- `bin/example`：入口占位，换成真实现。
- `tests/run-tests.sh`：五个断言覆盖「入口可执行 / 安装落地 / --check 认可 / --check 检出漂移 / 卸载干净」。
- `docs/handoff.md`：交接骨架，按「当前状态 / 怎么做 / 未决事项 / 复现方法」组织。
- `README.md`：五段骨架（问题 / 做法 / 用法 / 验证 / 许可），占位写成 `{{...}}`。

## pkgbuild-project 给了什么

- `PKGBUILD`：`make`/`install` 骨架，`sha256sums` 留成 `SKIP` 并在注释里写了换成 `updpkgsums` 的时机。
- `build.sh`：`makepkg -si` 的薄封装，参数原样透传。
- `.gitignore`：直接覆盖 `src/`、`pkg/`、`*.pkg.tar.zst`、源码包——这是 R5 最容易踩的一条。
- `README.md`：五段骨架，用法里给出 `./build.sh` 与清工作目录的 `makepkg -sc`。

两个模板都不含 `.github/`：CI 工作流属于推荐层（W1），按项目需要再加。
