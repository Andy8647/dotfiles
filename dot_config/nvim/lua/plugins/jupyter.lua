return {
  -- inline 图片渲染(matplotlib 图直接显示在 nvim 里)
  -- Ghostty 支持 Kitty graphics protocol;magick_cli 走刚装的 ImageMagick CLI,
  -- 避开 magick luarock 要 Lua 5.1 编译的坑
  {
    "3rd/image.nvim",
    lazy = true,
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = { enabled = false },
        neorg = { enabled = false },
      },
      max_width_window_percentage = 60,
      window_overlap_clear_enabled = true,
    },
  },

  -- 原生 .ipynb 编辑:cell 导航 / 执行 / 输出内联 / 变量浏览器
  -- 用法:直接 nvim xxx.ipynb,kernel 自动启动
  --   <CR> 进入 cell 编辑,<Esc><Esc> 退回 cell 导航
  --   <leader>rc 跑当前 cell,<leader>ra 全跑,<leader>ru/rd 跑上/下方所有 cell
  --   l 折叠/展开输出,dd 删 cell,<leader>bt 下方加 cell
  --   <leader>ve 变量浏览器,<leader>ut undo tree
  {
    "Andy8647/nvim-jupyter", -- fork:per-cell-type 高亮组(PR 合并后切回 abdelwahab-7/nvim-jupyter)
    dir = vim.fn.expand("~/Projects/fork/nvim-jupyter"), -- dev 模式:直接用本地 clone,分支在 repo 里自己切
    lazy = false, -- 必须非 lazy,BufReadCmd 才能拦截 .ipynb
    dependencies = { "3rd/image.nvim" },
    init = function()
      -- 插件硬编码 jobstart({"python3", ...}) 起后台 server.py,
      -- 把专用 venv 提到 PATH 最前,让它用对 python(pyenv 全局是干净的,没有 jupyter_client)
      vim.env.PATH = vim.fn.expand("~/.local/share/nvim-python3/bin") .. ":" .. vim.env.PATH

      -- nvim-jupyter 用 BufReadCmd 拦截 .ipynb,会截断 lazy.nvim 的 LazyFile 事件链,
      -- 导致 nvim-treesitter 不加载、Markdown cell 只剩 vim 自带 regex 语法(灰斜体),
      -- lspconfig/mason 不加载、LSP 不 attach(Trouble symbols 等功能全哑)。
      -- 这里在打开 notebook 后手动补齐:加载 treesitter + LSP 栈,再重触发 FileType。
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.ipynb",
        callback = function(ev)
          if not vim.b[ev.buf].is_jupyter then
            return
          end
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(ev.buf) then
              return
            end
            local need_lsp = #vim.lsp.get_clients({ bufnr = ev.buf }) == 0
            require("lazy").load({
              plugins = { "nvim-lspconfig", "mason-lspconfig.nvim", "mason.nvim", "nvim-treesitter" },
            })
            -- 重触发 FileType:让 pyright/ruff attach,并让 nvim-treesitter 启动高亮
            if need_lsp or not vim.b[ev.buf].ts_highlight then
              vim.api.nvim_buf_call(ev.buf, function()
                vim.bo.filetype = ""
                vim.bo.filetype = "python"
              end)
            end
          end)
        end,
      })
    end,
    opts = {},
    config = function(_, opts)
      require("nvim_jupyter").setup(opts)
      -- cell 边框配色(catppuccin 色板):
      --   markdown = 绿, code = 灰, output = 暗灰(跑完后被状态色覆盖)
      --   active 版本更亮 + bold
      local hl = vim.api.nvim_set_hl
      hl(0, "JupyterBorderMarkdown", { fg = "#7fb88a" }) -- 柔和绿
      hl(0, "JupyterBorderCode", { fg = "#CBA6F7" }) -- catppuccin mocha mauve,常亮
      hl(0, "JupyterBorderOutput", { fg = "#585B70" }) -- 更暗一档
      hl(0, "JupyterBorderActiveMarkdown", { fg = "#A6E3A1", bold = true })
      hl(0, "JupyterBorderActiveCode", { fg = "#CBA6F7", bold = true }) -- 同色系 + bold 区分激活
      hl(0, "JupyterBorderActiveOutput", { fg = "#89B4FA", bold = true })
    end,
  },
}
