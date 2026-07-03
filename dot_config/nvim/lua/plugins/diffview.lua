return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
    { "<leader>gv", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current)" },
    { "<leader>gV", "<cmd>DiffviewFileHistory<cr>", desc = "File History (repo)" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      -- three-way merge layout: OURS | result | THEIRS, like JetBrains
      merge_tool = {
        layout = "diff3_mixed",
        disable_diagnostics = true,
      },
    },
  },
}
