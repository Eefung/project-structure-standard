# {{项目名}}

{{一句话：它解决什么问题，谁用。}}

## How it works

{{一段话说清它怎么做的。必要时列组件：}}

| 文件 | 职责 |
|---|---|
| `install.sh` | 安装、`--check` 校验已装副本、`--uninstall` 卸载 |
| `bin/example` | 用户直接运行的入口 |
| `tests/run-tests.sh` | 回归测试 |
| `docs/handoff.md` | 交接文档：当前状态、未决事项、复现方法 |

## Install

```sh
./install.sh
```

装到 `~/.local/bin`（若设了 `XDG_BIN_HOME` 则装到那里），不需要 sudo。确认该目录在 `PATH` 里。重复执行安全。

## Usage

```sh
./install.sh --check      # 校验已装副本与仓库一致，不一致返回 1
./install.sh --uninstall  # 只删本项目装的文件
example                   # 跑起来（换成真实入口名）
```

在 {{发行版与内核，如 CachyOS / Linux 7.3.3-1-cachyos}}、{{shell，如 bash 5.x}} 上已验证。

## Documentation

- [`docs/handoff.md`](docs/handoff.md) — 交接文档：当前状态、未决事项、复现方法
- `tests/run-tests.sh` — 回归测试，覆盖安装、校验、卸载闭环

## License

MIT，见 [LICENSE](LICENSE)。
