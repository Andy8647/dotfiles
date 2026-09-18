-- 让 .git/info/exclude 里被 git 忽略的 AI 指令文件，在 snacks 里照样看得见
--
-- 为什么会消失：
--   1) snacks 的文件树靠 `git status --ignored` 判断节点是否 ignored，
--      AGENTS.md 一旦进了 .git/info/exclude 就被标成 ignored -> 从树里消失；
--   2) picker / grep 用的是 fd 和 rg，这两个也会读 .git/info/exclude。
--
-- 只想临时看一眼，不用改配置：
--   文件树里按 `I`，picker 里按 `<a-i>`，都是 toggle_ignored（会把 node_modules 一起放出来）
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          -- include 的优先级高于 ignored / hidden / exclude
          include = {
            "AGENTS.md",
            "AGENTS.override.md",
            "CLAUDE.md",
            "CLAUDE.local.md",
            "GEMINI.md",
            ".cursorrules",
            -- 点目录里的文件，得把目录本身也 include 进来，否则展不开
            ".cursor",
            ".cursor/rules",
            ".trae",
            ".trae/rules",
            ".codex",
            ".codex/config.toml",
            ".github", -- 只是为了能展开进去；不想要就换成 .github/instructions 的下层写法并接受 .github 不可见
            ".github/instructions",
          },
        },
      },
    },
  },
}
