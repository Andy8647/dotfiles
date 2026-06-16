# Andy's Global Claude Config

> 此文件会被**所有项目**加载,保持精简。项目专属信息放到各自的 `CLAUDE.md`。

## Environment

- **OS**: macOS (Darwin, Apple Silicon)
- **Shell**: fish(不是 bash/zsh — 给我执行的命令请用 fish 语法)
- **Terminal**: Ghostty
- **Prompt**: Starship
- **Font**: Maple Mono NF(带 Nerd Font 图标,`eza` 等工具的图标靠它)
- **Editor**: Neovim / VS Code / JetBrains IDE

## Fish 语法要点(生成命令时)

- 命令替换:`(cmd)` 不是 `$(cmd)`
- 环境变量:`set -x FOO bar` 不是 `export FOO=bar`
- 数组:`set arr a b c`,访问 `$arr[1]`
- 条件:`; and` / `; or` 替代 `&&` / `||`
- 不支持 `<<<` here-string

## Installed CLI Tools

完整速查表在 **`~/cli-cheatsheet.md`**,**按需 Read**,不要一次性加载进 context。

日常常备(假定可用):
`fd, eza, bat, rg (ripgrep), fzf, zoxide (z), sad, jq, httpie, gh, delta, lazygit (lg), yazi (y), btop, dust, procs, hyperfine, tldr, glow, tailspin, zellij, chezmoi, tokei, fastfetch, neovim`

已配置的 abbreviations:
`v=nvim`, `g=git`, `gs=git status -sb`, `gp/gl/gd/gc`, `lg=lazygit`, `y=yazi`

## Python 工作流(重要)

- **全局 pip 已清理**,不要再往全局装包
- **所有 Python 项目一律用 uv**:`uv venv` + `uv pip install -r requirements.txt`(或 `uv add` / `uv sync`)
- **CLI 工具**用 `uv tool install`(见下方"uv tool CLIs")
- **Jupyter**:每个项目自己的 `.venv` + `ipykernel`,VS Code 自动发现;**不要**注册全局 kernel
- **一次性脚本**:`uv run --with <pkg> python -c '...'`
- **Python 版本**由 pyenv 管理(当前全局 3.13.7)

## uv tool CLIs(已安装的社交/发布/工具链 CLI)

| 命令 | 工具 | 用途 |
|---|---|---|
| `xhs` | xiaohongshu-cli | 小红书发布 / 浏览 / 互动(配合 `xhs-post` skill 更佳) |
| `twitter` | twitter-cli | X / Twitter 发布 / 浏览;支持 `-c` 紧凑输出,LLM 友好 |
| `specify` | specify-cli | GitHub Spec Kit,spec-driven development 项目模板 |

具体命令见 `~/cli-cheatsheet.md`(按需 Read)。

## 包管理优先级

| 场景 | 用什么 |
|---|---|
| macOS 软件(CLI/GUI) | **Homebrew**(`brew install` / `brew install --cask`) |
| Python 项目依赖 | **uv** |
| Python CLI 工具 | **uv tool** |
| Node 项目 | **pnpm** 优先,除非项目强制 npm |
| dotfile 同步 | **chezmoi** — 改 `~/.config/` 下文件后提醒我同步 |

## Obsidian Vault (iCloud)

| Vault | 路径 | 用途 |
|---|---|---|
| **Vault** ⭐ | `$vault`(= `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault`) | 统一 vault:`UNSW/`(LLM-compiled 学校知识库,Karpathy 风格)+ `Ideas/` + `Projects/` + `Bridge/`。编译范围严格限制在 `Vault/UNSW/`,见 vault 内 `CLAUDE.md` 的 Compile Scope。 |

旧的 MyVault 已并入 Vault(归档为 `Obsidian/MyVault.OLD-to-remove-after-verify`,验证 OK 后可删)。

## Personal OS

`~/Projects/me/` — 手动维护的深度个人档案(履历、价值观、复盘、反复踩的坑)。
**不要**在其他项目中主动加载或引用其内容;只在用户 `cd ~/Projects/me` 时才生效。

## 沟通风格

- 回答用**中文(简体)**;技术术语保留英文(transformer, embedding, kernel 等)
- 简洁直接,不堆砌 emoji,不做冗长总结
- 我问"怎么做 X"时:先给**一条**推荐方案 + 主要权衡,必要时再给备选,不要一上来罗列五种
- 纠正错误要直接,不要包装成"你说得对,但是……"
- 我喜欢在回答里看到**你的判断**,不要只做选项搬运工

## 保护性规则(破坏性操作)

未经我明示同意,**不要**执行:
- `rm -rf`、`git push --force`、`git reset --hard`
- `brew uninstall` / `pip uninstall` 任何包
- `pyenv uninstall`、删除 `.venv` 或 `node_modules`
- 修改 `~/.zshrc` / `~/.config/fish/config.fish` / `~/.ssh/` / `~/.gnupg/`
- 关闭、重启、登出系统

执行前给出清单或 diff 预览,我确认后再动手。

@RTK.md
