-- 进入 / 切回 Neovim 时自动把输入法切成英文(ABC)。
-- Andy 几乎不在 nvim 打中文,所以这里强制英文、不自动切回中文。
-- 关键是 FocusGained:在 Ghostty 里从别的 tab 切回 nvim tab(终端会上报 focus)
-- 会立刻触发,把输入法翻成英文 —— 正好治「切 tab 带着中文输入法」的毛病。
return {
  "keaising/im-select.nvim",
  event = "VeryLazy",
  config = function()
    require("im_select").setup({
      default_im_select = "com.apple.keylayout.US",
      default_command = "macism",
      -- 这些事件发生时切回英文
      set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
      -- 留空:从不自动切回中文,nvim 始终保持英文
      set_previous_events = {},
      keep_quiet_on_no_binary = true,
    })
  end,
}
