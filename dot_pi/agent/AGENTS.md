# Andy's Global Pi Config

> 此文件会被**所有 pi session** 加载,保持精简。项目专属信息放到各项目的 `.pi/AGENTS.md`。

## ⚠️ Shell 语法 (每次执行命令前必读)

> **Pi 的 bash tool 实际运行的是 `/bin/bash` (macOS 自带 3.2.57),不是 fish。**
> 虽然登录 shell 是 fish(`echo $SHELL` 会显示 fish),但那只是登录 shell,
> 与 bash tool 的执行 shell 无关。**写标准 bash/POSIX 语法,写 fish 语法会直接报错。**

| 动作 | ✅ bash (必须用) | ❌ fish (会报错) |
|------|-------------------|-------------------|
| 条件链: 前一个成功才继续 | `cmd1 && cmd2` | `cmd1; and cmd2` |
| 条件链: 前一个失败才继续 | `cmd1 \|\| cmd2` | `cmd1; or cmd2` |
| 命令替换 | `$(cmd)` | `(cmd)` |
| 设置环境变量 | `export FOO=bar` | `set -x FOO bar` |
| here-string | `<<< "text"` | 不支持 |

**关键规则**:
- 直接用 `&&` / `||` / `$(...)` / `export`,这是标准 bash
- 不要用 bash 4+ 特性(关联数组、`mapfile`、`**` globstar),系统 bash 只有 3.2
- 把多步命令拆成多次 bash tool 调用比强行写长链更安全
- **不要被 `$SHELL=fish` 误导** —— bash tool 跑的是 `/bin/bash`,与登录 shell 无关

## Environment

- **OS**: macOS (Darwin, Apple Silicon)
- **Shell**: fish (仅登录 shell; pi 的 bash tool 用 `/bin/bash` 3.2,见上方 Shell 语法一节)
- **Terminal**: Ghostty
- **Prompt**: Starship
- **Font**: Maple Mono NF (带 Nerd Font 图标)
- **Editor**: Neovim / VS Code / JetBrains IDE

## 常用 CLI

日常常备: `fd, eza, bat, rg, fzf, zoxide (z), sad, jq, httpie, gh, delta, lazygit (lg), yazi (y), btop, dust, procs, hyperfine, tldr, glow, tailspin, zellij, chezmoi, tokei, fastfetch, neovim`

## 包管理优先级

| 场景 | 用什么 |
|------|--------|
| macOS 软件 | **Homebrew** |
| Python 项目 | **uv** (`uv venv` + `uv pip install` / `uv sync`) |
| Python CLI | **uv tool install** |
| Node 项目 | **pnpm** 优先,除非项目强制 npm |
| dotfile 同步 | **chezmoi** |

## Python 工作流

- 全局 pip 已清理,不要往全局装包
- 所有项目用 uv: `uv venv` + `uv sync` / `uv pip install`
- Jupyter: 每个项目自己的 `.venv` + `ipykernel`,不注册全局 kernel
- 一次性脚本: `uv run --with <pkg> python -c '...'`
- Python 版本由 pyenv 管理(全局 3.13.7)

## uv tool CLIs (已安装的 Python CLI 工具)

| 命令      | 工具            | 用途                                                |
| --------- | --------------- | --------------------------------------------------- |
| `xhs`     | xiaohongshu-cli | 小红书发布 / 浏览 / 互动                            |
| `twitter` | twitter-cli     | X / Twitter 发布 / 浏览;支持 `-c` 紧凑输出,LLM 友好 |

> 完整 CLI 速查表在 `~/cli-cheatsheet.md`,按需 Read,不要一次性加载进 context。

## 浏览器自动化 (chrome-devtools MCP)

当 webfetch 无法触及需要登录/JS 渲染的网站,或需要模拟手动操作时,用这套:

```bash
# 启动带 --remote-debugging-port=9222 的独立 Chrome 实例
chrome-debug          # 默认 9222 端口;已运行则复用
chrome-debug 9223     # 指定端口
```

Chrome DevTools MCP 已配置在 `~/.pi/agent/mcp.json`,连接到 `http://127.0.0.1:9222`。可直接使用 chrome-devtools 系列工具(mcp 目录下):
- `chrome_devtools_navigate_page` — 导航到 URL
- `chrome_devtools_take_snapshot` — 获取页面 a11y tree 文本快照
- `chrome_devtools_click` / `fill` / `press_key` — 模拟交互
- `chrome_devtools_evaluate_script` — 执行 JS
- `chrome_devtools_take_screenshot` — 截图

典型流程: `chrome-debug` → navigate → snapshot → 分析页面 → 操作 → snapshot 验证。

## ~/Projects 目录组织(重要:决定索引/搜索范围)

顶层是**「状态/类型分桶」+「活跃项目直放根目录」**的混合。repo 在哪个桶 = 它的状态。

| 位置 | 含义 |
| --- | --- |
| `~/Projects/<repo>`(根目录直放) | **当前活跃、正经在做**(如 `permafrost` `commonsku-copilot` `CarbCyclingWeb` `self-host-proxy`) |
| `.archive/`(dot 前缀,`ls` 隐藏) | **已完成/归档/死项目**(课程作业、旧实验),~28 个 |
| `paused/` | **暂停搁置** |
| `ideas/` | **早期想法,未认真启动** |
| `fork/` | **fork 的第三方 repo**;改上游时「上游 + 自己扩展」嵌套并排(`fork/pi/` = 上游 `pi/` + 我的 `pi-*` 扩展) |
| `Andy8647/` | GitHub profile repo(同名特殊仓库) |
| `DataGrip/` | 非代码,JetBrains DataGrip 工作区(只有 `.idea`) |

**惯例**:dot 前缀 = 组织桶;状态分桶 完成→`.archive`、搁置→`paused`、早期→`ideas`;活跃项目**直接摆根目录不套桶**;monorepo 用 `apps/ server/ ui/ infra/ scripts/ docs/`。

**默认索引/搜索范围**:代码分析、批量索引(jcodemunch)、跨 repo 搜索**默认只聚焦活跃项目**(`~/Projects` 根目录直放的 repo + `fork/pi/` 里我在改的),**跳过** `.archive/` `paused/` `ideas/` `node_modules/` `DataGrip/`。要碰归档/暂停/依赖里的东西,先跟我确认。

## 沟通风格

- 回答用**中文(简体)**;技术术语保留英文
- 简洁直接,不堆砌 emoji
- 纠正错误直接,不要包装成"你说得对,但是..."
- 给出判断,不只做选项搬运工
- 执行前给出 diff 预览,确认后再动手
