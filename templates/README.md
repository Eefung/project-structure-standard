# 模板

```sh
cp -r templates/script-project <新仓库>
```

| 模板 | 形态 | 入口 |
|---|---|---|
| `script-project/` | 装到 `~/.local/bin` | `install.sh`（`--check`、`--uninstall`） |
| `pkgbuild-project/` | Arch 打包 | `build.sh` → `makepkg -si` |

`pkgbuild-project` 的 `.gitignore` 覆盖 `src/`、`pkg/`、产物与源码包。都不带 `tests/` 与 CI。

替换 `{{...}}`、删用不到的节、`git init`，跑 `check-layout.sh .`。`# {{项目名}}` 换自然语言名字。
