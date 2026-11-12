# 项目结构规范

`~/Projects` 下仓库的 README 结构与目录布局。检查器判机械项（词与序），技能判判断项（该不该有）；规范本体是 [`skills/repo-layout-convention/SKILL.md`](skills/repo-layout-convention/SKILL.md)。

## 安装

```sh
git clone https://github.com/Eefung/project-structure-standard.git
cp -r skills/repo-layout-convention <技能目录>
```

## 用法

```sh
scripts/check-layout.sh <仓库>      # 逐条 ✓／✗
scripts/check-layout.sh -q <仓库>   # 只看 ✗
```

退出码 0／1／2：通过／有不通过项／用法错。依赖 bash 4+、git、GNU coreutils；CachyOS、bash 5.x 上验证。

## 开发

```sh
ln -sfn "$PWD/skills/repo-layout-convention" <技能目录>/repo-layout-convention
```

改词表同一次提交改 `SKILL.md` 与 `scripts/check-layout.sh`。

## 许可

MIT，见 [`LICENSE`](LICENSE)。
