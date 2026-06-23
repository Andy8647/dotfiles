-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 鼠标跳转定义（终端里 Cmd+click 收不到，用 Ctrl+click 代替 VSCode 的 Cmd+click）
-- 先 <LeftMouse> 把光标移到点击处，再触发 LSP 跳定义
vim.keymap.set("n", "<C-LeftMouse>", "<LeftMouse><cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Goto Definition (click)" })
-- Ctrl+右键 = 跳回上一个位置（相当于浏览器的“后退”）
vim.keymap.set("n", "<C-RightMouse>", "<LeftMouse><C-o>", { desc = "Jump back" })
