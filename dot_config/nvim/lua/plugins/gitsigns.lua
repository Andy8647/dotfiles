-- GitLens 同款：当前行尾显示「谁 + 何时 + commit 摘要」的行内 blame
-- gitsigns 是 LazyVim 自带的，这里只做增量覆盖
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 显示在行尾
      delay = 300, -- 光标停留 300ms 后出现
      ignore_whitespace = false,
    },
    -- 格式：作者, 相对时间 · commit 摘要
    current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d> · <summary>",
  },
  keys = {
    -- 切换行内 blame 显示
    { "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle line blame" },
    -- 弹出完整 blame（含完整 commit 信息），类似 GitLens 的 hover
    { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Blame line (full)" },
  },
}
