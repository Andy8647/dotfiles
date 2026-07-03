-- VSCode 同款光标平滑移动（终端里用拖尾 smear 模拟）
return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  opts = {
    -- 透明背景下别用背景色填充，靠字符画轨迹，避免出现黑块
    legacy_computing_symbols_support = true,
    -- 动画顺滑度（越小越快收尾；默认 0.25 偏慢，调快一点更像 VSCode）
    stiffness = 0.5,
    trailing_stiffness = 0.4,
    distance_stop_animating = 0.5,
    -- 普通水平/垂直移动也启用（默认只在跳跃时 smear）
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,
  },
}
