-- ~/.config/nvim/lua/plugins/latex.lua
return {
  {
    "lervag/vimtex",
    lazy = false,
    config = function()
      vim.g.vimtex_view_method = "skim" -- 或者 "skim" / "sioyek" / "okular"
      vim.g.vimtex_compiler_method = "latexmk"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "latex" },
    },
  },
}
