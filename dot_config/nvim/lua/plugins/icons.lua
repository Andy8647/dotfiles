-- ~/.config/nvim/lua/plugins/icons.lua
-- 图标方案:以 mini.icons 为底座(LazyVim 默认 + 原生集成 + 支持按目录名自定义),
--          借 VS Code Material Icon Theme 的"按文件夹名给专属图标"理念,自己扩一套目录图标表。
--
-- ── glyph 用 \u{} 码点写,避免源码里塞裸字形导致乱码 ──
--   码点全部取自 Font Awesome 经典区(Nerd Font / Maple Mono NF 一定带)。
--   查码点:https://www.nerdfonts.com/cheat-sheet(用 fa- 前缀最稳)
--   hl 可选:MiniIcons{Red,Orange,Yellow,Green,Cyan,Azure,Blue,Purple,Grey}
--
-- ── 想加新文件夹图标 ──
--   往下面 dir 表里加一行 名字 = ico("\u{码点}", "颜色"),重启 nvim 生效。

local function ico(glyph, hl)
  return { glyph = glyph, hl = "MiniIcons" .. hl }
end

-- 按文件夹名 → 图标 的映射(语义配色,不求和 VS Code 像素级一致)
local dir = {
  --── Monorepo / 顶层结构 ──
  apps          = ico("\u{f009}", "Azure"), -- th-large
  packages      = ico("\u{f1b3}", "Yellow"), -- cubes
  package       = ico("\u{f1b2}", "Yellow"), -- cube
  modules       = ico("\u{f1b3}", "Blue"),
  plugins       = ico("\u{f1e6}", "Green"), -- plug
  extensions    = ico("\u{f1e6}", "Green"),
  addons        = ico("\u{f1e6}", "Green"),
  workspace     = ico("\u{f0e8}", "Azure"), -- sitemap
  workspaces    = ico("\u{f0e8}", "Azure"),

  --── 基础设施 / 运维 ──
  infra         = ico("\u{f0a0}", "Grey"), -- hdd
  infrastructure = ico("\u{f0a0}", "Grey"),
  terraform     = ico("\u{f0a0}", "Purple"),
  ops           = ico("\u{f085}", "Grey"), -- cogs
  devops        = ico("\u{f085}", "Grey"),
  docker        = ico("\u{f085}", "Blue"),
  k8s           = ico("\u{f085}", "Blue"),
  kubernetes    = ico("\u{f085}", "Blue"),
  ci            = ico("\u{f085}", "Green"),
  deploy        = ico("\u{f135}", "Cyan"), -- rocket
  deployment    = ico("\u{f135}", "Cyan"),

  --── 源码骨架 ──
  src           = ico("\u{f121}", "Purple"), -- code
  source        = ico("\u{f121}", "Purple"),
  app           = ico("\u{f135}", "Azure"), -- rocket
  main          = ico("\u{f121}", "Purple"),
  core          = ico("\u{f2db}", "Red"), -- microchip
  common        = ico("\u{f1b3}", "Grey"),
  shared        = ico("\u{f1e0}", "Cyan"), -- share-alt
  lib           = ico("\u{f1b3}", "Yellow"), -- cubes
  libs          = ico("\u{f1b3}", "Yellow"),

  --── 前端结构 ──
  components    = ico("\u{f12e}", "Azure"), -- puzzle-piece
  component     = ico("\u{f12e}", "Azure"),
  widgets       = ico("\u{f12e}", "Azure"),
  ui            = ico("\u{f12e}", "Cyan"),
  elements      = ico("\u{f12e}", "Cyan"),
  hooks         = ico("\u{f13d}", "Orange"), -- anchor
  composables   = ico("\u{f13d}", "Orange"),
  mixins        = ico("\u{f0ec}", "Cyan"), -- exchange
  directives    = ico("\u{f0e8}", "Cyan"),
  context       = ico("\u{f1e0}", "Cyan"),
  contexts      = ico("\u{f1e0}", "Cyan"),
  providers     = ico("\u{f1e0}", "Cyan"),
  store         = ico("\u{f1c0}", "Green"), -- database
  stores        = ico("\u{f1c0}", "Green"),
  state         = ico("\u{f1c0}", "Green"),
  redux         = ico("\u{f1c0}", "Purple"),
  styles        = ico("\u{f1fc}", "Purple"), -- paint-brush
  css           = ico("\u{f13c}", "Blue"), -- css3
  scss          = ico("\u{f1fc}", "Purple"),
  sass          = ico("\u{f1fc}", "Purple"),
  themes        = ico("\u{f1fc}", "Cyan"),
  fonts         = ico("\u{f031}", "Grey"), -- font
  layout        = ico("\u{f0db}", "Purple"), -- columns
  layouts       = ico("\u{f0db}", "Purple"),
  pages         = ico("\u{f15c}", "Azure"), -- file-text
  page          = ico("\u{f15c}", "Azure"),
  views         = ico("\u{f15c}", "Azure"),
  view          = ico("\u{f15c}", "Azure"),
  screens       = ico("\u{f108}", "Azure"), -- desktop
  templates     = ico("\u{f15b}", "Blue"), -- file
  partials      = ico("\u{f15b}", "Blue"),

  --── 后端 / 服务 ──
  routes        = ico("\u{f0e8}", "Green"), -- sitemap
  router        = ico("\u{f0e8}", "Green"),
  api           = ico("\u{f1e6}", "Green"), -- plug
  apis          = ico("\u{f1e6}", "Green"),
  server        = ico("\u{f233}", "Blue"), -- server
  services      = ico("\u{f233}", "Blue"),
  service       = ico("\u{f233}", "Blue"),
  controllers   = ico("\u{f085}", "Blue"), -- cogs
  controller    = ico("\u{f085}", "Blue"),
  handlers      = ico("\u{f085}", "Grey"),
  resolvers     = ico("\u{f0e8}", "Green"),
  graphql       = ico("\u{f0e8}", "Purple"),
  models        = ico("\u{f1b2}", "Orange"), -- cube
  model         = ico("\u{f1b2}", "Orange"),
  entities      = ico("\u{f1b2}", "Orange"),
  schemas       = ico("\u{f0e8}", "Orange"),
  schema        = ico("\u{f0e8}", "Orange"),
  repositories  = ico("\u{f1c0}", "Blue"),
  repos         = ico("\u{f1c0}", "Blue"),
  dao           = ico("\u{f1c0}", "Blue"),
  middleware    = ico("\u{f0ec}", "Grey"), -- exchange
  middlewares   = ico("\u{f0ec}", "Grey"),
  interceptors  = ico("\u{f0ec}", "Grey"),
  filters       = ico("\u{f0b0}", "Grey"), -- filter
  pipes         = ico("\u{f0ec}", "Grey"),
  decorators    = ico("\u{f043}", "Purple"), -- tint
  guards        = ico("\u{f023}", "Red"), -- lock
  types         = ico("\u{f02c}", "Blue"), -- tags
  interfaces    = ico("\u{f02c}", "Blue"),
  dto           = ico("\u{f02c}", "Blue"),
  enums         = ico("\u{f02c}", "Blue"),

  --── 安全 / 鉴权 ──
  auth          = ico("\u{f084}", "Yellow"), -- key
  authentication = ico("\u{f084}", "Yellow"),
  security      = ico("\u{f023}", "Red"), -- lock
  validators    = ico("\u{f14a}", "Green"), -- check-square
  validation    = ico("\u{f14a}", "Green"),

  --── 工程通用 ──
  utils         = ico("\u{f0ad}", "Grey"), -- wrench
  util          = ico("\u{f0ad}", "Grey"),
  helpers       = ico("\u{f0ad}", "Grey"),
  helper        = ico("\u{f0ad}", "Grey"),
  tools         = ico("\u{f0ad}", "Grey"),
  config        = ico("\u{f013}", "Grey"), -- cog
  configs       = ico("\u{f013}", "Grey"),
  settings      = ico("\u{f013}", "Grey"),
  env           = ico("\u{f013}", "Green"),
  constants     = ico("\u{f292}", "Grey"), -- hashtag
  scripts       = ico("\u{f120}", "Green"), -- terminal
  bin           = ico("\u{f120}", "Grey"),
  cli           = ico("\u{f120}", "Cyan"),
  tasks         = ico("\u{f0ae}", "Green"), -- tasks
  jobs          = ico("\u{f0ae}", "Green"),
  workers       = ico("\u{f085}", "Orange"),
  queues        = ico("\u{f03a}", "Grey"), -- list
  cron          = ico("\u{f017}", "Grey"), -- clock

  --── 资源 / 内容 ──
  public        = ico("\u{f0ac}", "Cyan"), -- globe
  static        = ico("\u{f0ac}", "Cyan"),
  assets        = ico("\u{f03e}", "Yellow"), -- image
  asset         = ico("\u{f03e}", "Yellow"),
  images        = ico("\u{f03e}", "Yellow"),
  image         = ico("\u{f03e}", "Yellow"),
  img           = ico("\u{f03e}", "Yellow"),
  icons         = ico("\u{f005}", "Yellow"), -- star
  media         = ico("\u{f008}", "Purple"), -- film
  video         = ico("\u{f008}", "Purple"),
  videos        = ico("\u{f008}", "Purple"),
  audio         = ico("\u{f001}", "Purple"), -- music
  sound         = ico("\u{f001}", "Purple"),
  docs          = ico("\u{f02d}", "Blue"), -- book
  doc           = ico("\u{f02d}", "Blue"),
  documentation = ico("\u{f02d}", "Blue"),
  content       = ico("\u{f15c}", "Blue"),
  posts         = ico("\u{f15c}", "Blue"),
  blog          = ico("\u{f15c}", "Blue"),
  i18n          = ico("\u{f1ab}", "Green"), -- language
  locales       = ico("\u{f1ab}", "Green"),
  lang          = ico("\u{f1ab}", "Green"),
  translations  = ico("\u{f1ab}", "Green"),

  --── 数据 ──
  data          = ico("\u{f1c0}", "Green"), -- database
  db            = ico("\u{f1c0}", "Green"),
  database      = ico("\u{f1c0}", "Green"),
  seeds         = ico("\u{f1c0}", "Green"),
  seeders       = ico("\u{f1c0}", "Green"),
  migrations    = ico("\u{f1c0}", "Orange"),
  fixtures      = ico("\u{f0c3}", "Orange"), -- flask

  --── 测试 ──
  test          = ico("\u{f0c3}", "Red"), -- flask
  tests         = ico("\u{f0c3}", "Red"),
  __tests__     = ico("\u{f0c3}", "Red"),
  spec          = ico("\u{f0c3}", "Red"),
  specs         = ico("\u{f0c3}", "Red"),
  e2e           = ico("\u{f0c3}", "Red"),
  cypress       = ico("\u{f0c3}", "Cyan"),
  mocks         = ico("\u{f24d}", "Grey"), -- clone
  fakes         = ico("\u{f24d}", "Grey"),
  coverage      = ico("\u{f200}", "Green"), -- pie-chart
  benchmarks    = ico("\u{f080}", "Green"), -- bar-chart
  ["test-data"] = ico("\u{f1c0}", "Orange"),

  --── 构建 / 产物 / 缓存 ──
  dist          = ico("\u{f187}", "Grey"), -- archive
  build         = ico("\u{f187}", "Grey"),
  out           = ico("\u{f187}", "Grey"),
  output        = ico("\u{f187}", "Grey"),
  target        = ico("\u{f140}", "Grey"), -- bullseye
  release       = ico("\u{f135}", "Green"), -- rocket
  releases      = ico("\u{f135}", "Green"),
  vendor        = ico("\u{f187}", "Grey"),
  node_modules  = ico("\u{f187}", "Red"),
  cache         = ico("\u{f0e7}", "Yellow"), -- bolt
  tmp           = ico("\u{f017}", "Grey"), -- clock
  temp          = ico("\u{f017}", "Grey"),
  logs          = ico("\u{f15c}", "Grey"), -- file-text
  log           = ico("\u{f15c}", "Grey"),

  --── 示例 / 沙盒 ──
  examples      = ico("\u{f0eb}", "Yellow"), -- lightbulb
  example       = ico("\u{f0eb}", "Yellow"),
  demo          = ico("\u{f0eb}", "Yellow"),
  demos         = ico("\u{f0eb}", "Yellow"),
  samples       = ico("\u{f0eb}", "Yellow"),
  playground    = ico("\u{f11b}", "Green"), -- gamepad
  sandbox       = ico("\u{f11b}", "Green"),
  snippets      = ico("\u{f121}", "Cyan"),

  --── 业务域(电商 / 后台常见)──
  users         = ico("\u{f0c0}", "Cyan"), -- users
  user          = ico("\u{f007}", "Cyan"), -- user
  admin         = ico("\u{f0e3}", "Red"), -- gavel
  dashboard     = ico("\u{f0e4}", "Cyan"), -- dashboard
  notifications = ico("\u{f0f3}", "Yellow"), -- bell
  email         = ico("\u{f0e0}", "Blue"), -- envelope
  mail          = ico("\u{f0e0}", "Blue"),
  payments      = ico("\u{f09d}", "Green"), -- credit-card
  billing       = ico("\u{f09d}", "Green"),
  cart          = ico("\u{f07a}", "Green"), -- shopping-cart
  products      = ico("\u{f290}", "Orange"), -- shopping-bag
  orders        = ico("\u{f291}", "Orange"), -- shopping-basket

  --── dotfolders(补 mini 没覆盖的)──
  [".vscode"]   = ico("\u{f085}", "Blue"),
  [".idea"]     = ico("\u{f085}", "Grey"),
  [".husky"]    = ico("\u{f13d}", "Grey"), -- anchor(git hook)
  [".circleci"] = ico("\u{f085}", "Green"),
}

return {
  {
    "nvim-mini/mini.icons",
    -- opts 会被 lazy.nvim 深合并进 LazyVim 的默认配置,只补 directory 表
    opts = {
      directory = dir,
    },
  },

  -- snacks explorer 补丁:展开目录时保留命名图标
  -- 原因:snacks/picker/format.lua 里 `if item.dir and item.open then icon = dir_open end`
  --       会把展开目录的图标无条件覆盖成通用 open-folder,丢掉 mini 的命名图标。
  -- 做法:展开且该目录有自定义命名图标(mini 非 default)时,把 dir_open 临时换成命名 glyph;
  --       没有命名图标的普通目录仍走默认 open-folder,行为不回退。
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local ok, format = pcall(require, "snacks.picker.format")
      if ok and not format._named_dir_patched then
        format._named_dir_patched = true
        local orig = format.filename
        format.filename = function(item, picker)
          local files = picker.opts and picker.opts.icons and picker.opts.icons.files
          if item.dir and item.open and files and files.enabled ~= false then
            local name = Snacks.picker.util.path(item) or item.file or ""
            local glyph, _, is_default = require("mini.icons").get("directory", name)
            if not is_default then
              local saved = files.dir_open
              files.dir_open = glyph
              local ret = orig(item, picker)
              files.dir_open = saved
              return ret
            end
          end
          return orig(item, picker)
        end
      end
      return opts
    end,
  },
}
