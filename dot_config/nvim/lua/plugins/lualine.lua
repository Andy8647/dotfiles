-- ~/.config/nvim/lua/plugins/lualine.lua
-- starship 风格的圆角状态栏(lualine "bubbles" 样式)
-- 半圆 glyph 需要 Nerd Font(Maple Mono NF 自带):
--   \u{e0b6} = 左半圆 '('   \u{e0b4} = 右半圆 ')'
return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    -- 段与段之间用圆角半圆过渡;组件之间不画分隔符(留空格即可)
    opts.options.section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" }
    opts.options.component_separators = ""

    local sections = opts.sections or {}

    -- 最左端加圆角帽 '('
    if sections.lualine_a and sections.lualine_a[1] then
      sections.lualine_a[1] = {
        sections.lualine_a[1],
        separator = { left = "\u{e0b6}" },
        right_padding = 2,
      }
    end

    -- 最右端加圆角帽 ')'
    if sections.lualine_z and #sections.lualine_z > 0 then
      local i = #sections.lualine_z
      sections.lualine_z[i] = {
        sections.lualine_z[i],
        separator = { right = "\u{e0b4}" },
        left_padding = 2,
      }
    end
  end,
}
