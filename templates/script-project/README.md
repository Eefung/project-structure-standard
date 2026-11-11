# {{项目名}}

{{一句话：它解决什么问题，谁用。项目名用自然语言写，不要只写仓库 slug。}}

## 原理

`install.sh` 把 `bin/example` 装到 `~/.local/bin`，`--check` 逐字节比对已装副本与仓库是否一致，`--uninstall` 只删带本项目标记的文件。`tests/run-tests.sh` 断言这条闭环：入口可执行、安装落地、校验认可、校验能检出漂移、卸载干净。

## 安装

```sh
./install.sh
```

装到 `~/.local/bin`（若设了 `XDG_BIN_HOME` 则装到那里），不需要 sudo。确认该目录在 `PATH` 里。重复执行安全。

## 用法

```sh
./install.sh --check      # 校验已装副本与仓库一致，不一致返回 1
./install.sh --uninstall  # 只删本项目装的文件
example                   # 跑起来（换成真实入口名）
```

在 {{发行版与内核，如 CachyOS / Linux 7.3.3-1-cachyos}}、{{shell，如 bash 5.x}} 上已验证。

## 文档

- [`docs/handoff.md`](docs/handoff.md) — 交接文档：当前状态、未决事项、复现方法

## 许可

MIT，见 [LICENSE](LICENSE)。
