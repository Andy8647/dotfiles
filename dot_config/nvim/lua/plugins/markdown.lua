-- 关掉 markdown 的 markdownlint 诊断(MD001/MD013/MD022/MD032 等风格提示)
return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
      opts.linters_by_ft["markdown.mdx"] = {}
      return opts
    end,
  },
}
