-- 让 Pyright/basedpyright 自动使用项目根下的 .venv/bin/python。
-- 这样任何用 `uv venv` 建出 .venv 的项目都会被自动识别,
-- 不需要再为每个项目手搓 pyrightconfig.json 或手动 :VenvSelect。
--
-- 前提:LSP 的 root_dir 能正确锚到项目根(pyright 靠 pyproject.toml /
-- setup.py / requirements.txt / pyrightconfig.json / .git 等标记定位)。
-- `uv init` 的项目都有 pyproject.toml,所以 root 会稳。

local function use_project_venv(new_config, root_dir)
  local py = root_dir .. "/.venv/bin/python"
  if vim.uv.fs_stat(py) then
    new_config.settings = new_config.settings or {}
    new_config.settings.python = new_config.settings.python or {}
    new_config.settings.python.pythonPath = py
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = { on_new_config = use_project_venv },
        basedpyright = { on_new_config = use_project_venv },
      },
    },
  },
}
