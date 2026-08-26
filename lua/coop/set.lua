vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.confirm = true

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
vim.opt.linebreak = true
vim.opt.breakindent = true -- Preserves indentation on wrapped lines

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

local fold_group = vim.api.nvim_create_augroup("FastFoldexpr", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
  group = fold_group,
  callback = function()
    vim.opt_local.foldmethod = "manual"
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = fold_group,
  callback = function()
    vim.opt_local.foldmethod = "expr"
  end,
})

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/state/nvim/undo"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8

vim.opt.cmdheight = 0
vim.opt.laststatus = 3

-- ── Live theme watcher ────────────────────────────────────────────────────────
local cache_dir = vim.fn.expand("~/.cache")
local live_theme_file = cache_dir .. "/nvim-live-theme"

local function apply_live_theme()
  local f = io.open(live_theme_file, "r")
  if not f then
    return
  end
  local cs = f:read("l")
  local bg = f:read("l")
  f:close()

  if not cs or cs == "" then
    return
  end

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
    vim.fn.mkdir(cache_dir, "p")
    local watcher = vim.uv.new_fs_event()
    if not watcher then
      return
    end

    watcher:start(
      cache_dir,
      { recursive = false },
      vim.schedule_wrap(function(err, filename, _)
        if not err and (filename == "nvim-live-theme" or not filename) then
          apply_live_theme()
        end
      end)
    )
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

-- ── File Save Notification ──────────────────────────────────────────────────
vim.api.nvim_create_autocmd("BufWritePost", {
  desc = "Notify when saving a file",
  callback = function(ev)
    local filename = vim.fn.fnamemodify(ev.file, ":t")
    vim.notify("Saved " .. filename, vim.log.levels.INFO, { title = "Buffer Saved" })
  end,
})

-- ── Auto Filetype & Treesitter Detection ──────────────────────────────────
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
  desc = "Auto-detect filetype on shebang for untyped buffers",
  callback = function(ev)
    if not vim.api.nvim_buf_is_valid(ev.buf) then
      return
    end
    if vim.bo[ev.buf].filetype == "" then
      local first_line = (vim.api.nvim_buf_get_lines(ev.buf, 0, 1, false)[1] or "")
      if first_line:match("^#!") then
        vim.cmd("filetype detect")
        if vim.bo[ev.buf].filetype ~= "" then
          pcall(vim.treesitter.start, ev.buf)
        end
      end
    end
  end,
})

-- ── Python PEP 8 Indentation (4 Spaces) ──────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  desc = "Enforce PEP 8 4-space indentation for Python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})
if vim.env.TMUX ~= nil then
  local tmux_group = vim.api.nvim_create_augroup("TmuxStatusToggle", { clear = true })
  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
    group = tmux_group,
    callback = function()
      vim.fn.system("tmux set status off")
    end,
  })
  vim.api.nvim_create_autocmd({ "VimLeave", "FocusLost" }, {
    group = tmux_group,
    callback = function()
      vim.fn.system("tmux set status on")
    end,
  })
end
