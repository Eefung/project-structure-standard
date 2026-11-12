# 模板

两个骨架，复制使用（不是 submodule）：

```sh
cp -r templates/script-project ~/Projects/<新仓库名>
```

| 模板 | 形态 | 入口 |
|---|---|---|
| `script-project/` | 脚本工具，装到 `~/.local/bin` | `install.sh`（`--check` / `--uninstall`） |
| `pkgbuild-project/` | Arch 打包 | `build.sh` → `makepkg -si` |

`script-project` 含 `install.sh`、入口占位 `bin/example`；`pkgbuild-project` 含 `PKGBUILD`（`sha256sums` 为 `SKIP`，注释写明何时换 `updpkgsums`）、`build.sh`、覆盖 `src/`／`pkg/`／产物与源码包的 `.gitignore`。两个都不带 `tests/` 与 CI。

复制后替换 `{{...}}`、删掉用不到的节、`git init`，在仓库根跑 `~/Projects/project-structure-standard/scripts/check-layout.sh .`。`# {{项目名}}` 换自然语言名字，不是仓库 slug；标题语言随正文。
