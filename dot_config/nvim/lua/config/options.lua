-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- -- 隐藏所有竖向分隔线：让它们的 fg = Normal 的 bg
local function hide_separators()
  local ok, normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal", link = false })
  local bg = ok and normal and normal.bg or nil
  -- 如果拿不到 bg，就退化为 NONE（尽量不出错）
  local color = bg or "NONE"

  -- nvim 0.9+ 的分隔线
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = color, bg = "NONE" })
  -- 一些主题/插件仍使用老的 VertSplit
  vim.api.nvim_set_hl(0, "VertSplit", { fg = color, bg = "NONE" })
  -- neo-tree 覆盖用的分隔线
  vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { fg = color, bg = "NONE" })
end

hide_separators()
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  callback = hide_separators,
})

--（可选）避免某些主题用字符画线，再把这些字符清空
vim.opt.fillchars = vim.tbl_deep_extend("force", vim.opt.fillchars:get(), {
  vert = " ",
  vertleft = " ",
  vertright = " ",
  verthoriz = " ",
  horiz = " ",
  horizup = " ",
  horizdown = " ",
  eob = " ",
})
