-- ~/.config/nvim/lua/plugins/latex.lua
return {
  {
    "lervag/vimtex",
    lazy = false,
    config = function()
      vim.g.vimtex_view_method = "skim" -- 或者 "sioyek" / "zathura"
      vim.g.vimtex_compiler_method = "latexmk"

      -- 全局默认引擎 = lualatex(文件里写 % !TEX program = xelatex 可单独覆盖)
      vim.g.vimtex_compiler_latexmk_engines = { ["_"] = "-lualatex" }
      -- latexmk 选项:加 -shell-escape 给 minted 用;其余保持 VimTeX 默认值
      vim.g.vimtex_compiler_latexmk = {
        out_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        hooks = {},
        options = {
          "-shell-escape", -- minted 代码高亮需要
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
      -- forward search: 编译后自动把 PDF 定位到光标行,并把 Skim 切到前台
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
      vim.g.vimtex_view_skim_reading_bar = 1
      -- 编译有 warning 时不要自动弹 quickfix
      vim.g.vimtex_quickfix_open_on_warning = 0

      -- 退出某个 tex 工程时自动清理中间文件(保留 PDF),等价于 VSCode 的 clean
      vim.api.nvim_create_autocmd("User", {
        pattern = "VimtexEventQuit",
        callback = function()
          vim.cmd("VimtexClean") -- 删 aux/log/out/synctex 等,不删 PDF
        end,
      })
    end,
  },
  -- 保存时用 latexindent 自动格式化(LazyVim 默认开启 format-on-save)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        tex = { "latexindent" },
        bib = { "latexindent" },
      },
      formatters = {
        latexindent = {
          -- -m 允许换行重排;-l 读本地 .latexindent.yaml 配置(如果有)
          prepend_args = { "-m", "-l" },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "latex", "bibtex" },
    },
  },
  -- texlab: 补全 / 诊断 / 引用跳转;编译和 forward-search 仍由 vimtex 负责
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          settings = {
            texlab = {
              build = { onSave = false }, -- 不让 texlab 自己编译,交给 vimtex
              chktex = { onOpenAndSave = true }, -- 保存时跑 chktex 语法检查
            },
          },
        },
      },
    },
  },
}
