vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.autoformat = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = true

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/state/nvim/undo"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8

vim.opt.cmdheight = 0



-- ── Live theme watcher ────────────────────────────────────────────────────────
local live_theme_file = vim.fn.expand("~/.cache/nvim-live-theme")

local function apply_live_theme()
  local f = io.open(live_theme_file, "r")
  if not f then return end
  local cs = f:read("l")
  local bg = f:read("l")
  f:close()

  if not cs or cs == "" then return end

  vim.schedule(function()
    if bg == "light" or bg == "dark" then
      vim.opt.background = bg
    end
    local ok, err = pcall(vim.cmd, "colorscheme " .. cs)
    if not ok then
      vim.notify("Live theme: " .. err, vim.log.levels.WARN)
    end
  end)
end

-- Apply current theme on startup
apply_live_theme()

-- Watch for theme changes hot-reloaded by `theme` script
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.fn.mkdir(vim.fn.expand("~/.cache"), "p")
    local watcher = vim.uv.new_fs_event()
    if not watcher then return end

    local function watch()
      watcher:start(live_theme_file, {}, function(err, _, _)
        watcher:stop()
        if not err then apply_live_theme() end
        vim.defer_fn(watch, 50)
      end)
    end

    local function try_arm()
      if vim.fn.filereadable(live_theme_file) == 1 then watch() else vim.defer_fn(try_arm, 1000) end
    end
    try_arm()
  end,
})

-- ── Markdown <mark> Highlight Rendering (Bold + Italic + Accent Color) ───────
function _G.set_markdown_highlight()
  local group_name = vim.g.markdown_highlight_group or "DiagnosticWarn"
  local hl = vim.api.nvim_get_hl(0, { name = group_name, link = false })
  local fg_color = hl.fg or hl.foreground
  local cterm_color = hl.ctermfg
  if not fg_color then
    local warn = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn", link = false })
    fg_color = warn.fg or warn.foreground
    cterm_color = warn.ctermfg
  end
  vim.api.nvim_set_hl(0, "RenderMarkdownInlineHighlight", {
    fg = fg_color,
    ctermfg = cterm_color,
    bold = true,
    italic = true,
    bg = "NONE",
    ctermbg = "NONE",
  })
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
  pattern = { "*.md", "markdown" },
  callback = function()
    vim.cmd([[
      syntax match MarkdownMarkHide /<\/\?mark>/ conceal
      syntax region MarkdownMarkText matchgroup=MarkdownMarkHide start=/<mark>/ end=/<\/mark>/ concealends
      hi def link MarkdownMarkText RenderMarkdownInlineHighlight
    ]])
  end,
})

_G.set_markdown_highlight()
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  callback = _G.set_markdown_highlight,
})
