-- Shell scripting tooling
--  · nvim-lint → shellcheck 诊断(自动按 shebang 区分 dash/bash/sh)
--  · bashls    → LSP:跳转定义 / hover / 引用(shellcheck 这些都不提供)
--
-- ⚠ bash-language-server 在【workspace 路径含空格】时跨文件 source 解析会失效
--   (实测:仅空格差异的两个目录,无空格能跳、带空格返回空)。Andy 的 vault 在
--   "~/Library/Mobile Documents/…",整条路径带空格 → 所有 shell 文件都跳不动。
--   解法:把 bashls 的 root_dir 指到一个【无空格的 symlink】(放 cache 里,按真实
--   路径哈希命名、首次自动建好);bashls 在无空格 root 上索引即可正常跳转。

local uv = vim.uv or vim.loop

-- Given a file, return its project root — but if that root contains a space,
-- return a stable space-free symlink to it instead (created on demand).
local function space_free_root(path)
  local util = require("lspconfig.util")
  local root = util.root_pattern(".git", ".shellcheckrc")(path) or vim.fs.dirname(path)
  if not root or not root:find(" ") then
    return root
  end
  local link = vim.fn.stdpath("cache") .. "/bashls-root/" .. vim.fn.sha256(root):sub(1, 16)
  vim.fn.mkdir(vim.fn.fnamemodify(link, ":h"), "p")
  if not uv.fs_lstat(link) then
    uv.fs_symlink(root, link)
  end
  return link
end

-- Works with both the classic lspconfig signature root_dir(fname) and the
-- newer root_dir(bufnr, on_dir) callback form.
local function bashls_root(a, on_dir)
  local fname = type(a) == "number" and vim.api.nvim_buf_get_name(a) or a
  local root = space_free_root(fname)
  if on_dir then
    on_dir(root)
  else
    return root
  end
end

return {
  -- diagnostics
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      },
    },
  },

  -- language server: go-to-definition / hover / references
  -- LazyVim 会按 opts.servers 自动用 mason 装 bash-language-server。
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {
          root_dir = bashls_root,
          -- bashls 自带的 shellcheck 集成会和上面的 nvim-lint 重复报诊断;关掉它。
          settings = {
            bashIde = {
              shellcheckPath = "",
            },
          },
        },
      },
    },
  },
}
