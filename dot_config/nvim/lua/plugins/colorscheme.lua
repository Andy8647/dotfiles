-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  {
    "navarasu/onedark.nvim",
    lazy = false, -- 启动即加载（避免还没加载就被 require）
    priority = 1000, -- 提前于其他插件
    opts = {
      -- 你的需求：cool + 透明
      style = "cool",
      transparent = true,
      term_colors = true,
      ending_tildes = false,
      cmp_itemkind_reverse = false,

      code_style = {
        comments = "italic",
        keywords = "none",
        functions = "none",
        strings = "none",
        variables = "none",
      },

      lualine = { transparent = true },

      -- 让各处也“看起来透明”
      highlights = {
        Normal = { bg = "none" },
        NormalNC = { bg = "none" },
        NormalFloat = { bg = "none" },
        FloatBorder = { bg = "none" },
        SignColumn = { bg = "none" },
        StatusLine = { bg = "none" },
        StatusLineNC = { bg = "none" },
      },

      diagnostics = {
        darker = true,
        undercurl = true,
        background = false,
      },
    },
    config = function(_, opts)
      require("onedark").setup(opts)
      require("onedark").load() -- 或者 vim.cmd.colorscheme("onedark")
    end,
  },
}
