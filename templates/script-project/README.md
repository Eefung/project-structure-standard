# {{项目名}}

{{一句话：它解决什么问题，谁用。}}

## 问题

{{什么情况下会痛。贴真实症状——报错原文、失效的组合键、多花的十分钟。不要写「效率不高」这类空话。}}

## 做法

{{一段话说清它怎么做的。必要时列组件：}}

| 文件 | 职责 |
|---|---|
| `install.sh` | 安装、`--check` 校验已装副本、`--uninstall` 卸载 |
| `bin/example` | 用户直接运行的入口 |
| `tests/run-tests.sh` | 回归测试 |
| `docs/handoff.md` | 交接文档：当前状态、未决事项、复现方法 |

## 用法

```sh
./install.sh              # 安装到 ~/.local/bin
./install.sh --check      # 校验已装副本与仓库一致
./install.sh --uninstall  # 只删本项目装的文件
```

## 验证

```sh
tests/run-tests.sh
```

### 已验证环境

- {{发行版与内核版本，如 CachyOS / Linux 7.3.3-1-cachyos}}
- {{shell 与版本，如 fish 4.x / bash 5.x}}

## 许可

MIT，见 [LICENSE](LICENSE)。
