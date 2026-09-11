local is_termux = vim.env.PREFIX and vim.env.PREFIX:match("com%.termux") ~= nil
if not vim.env.XDG_RUNTIME_DIR and is_termux then
  vim.env.XDG_RUNTIME_DIR = vim.env.TMPDIR or "/data/data/com.termux/files/usr/tmp"
end
vim.opt.statusline = "%f %m %= %{%v:lua.vim.lsp.status()%} %l:%c"

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
  desc = "Highlight and position cursor at end of yanked text",
  callback = function()
    vim.highlight.on_yank()
    if vim.v.event.operator == "y" then
      pcall(vim.api.nvim_win_set_cursor, 0, vim.api.nvim_buf_get_mark(0, "]"))
    end
  end,
})

-- Folding
vim.opt.foldmethod = "manual"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = false

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

local md_syntax_group = vim.api.nvim_create_augroup("MarkdownMarkSyntax", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = md_syntax_group,
  pattern = "markdown",
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

-- ── Dynamic SignColumn & GitSigns Background Sync ───────────────────────────
local function sync_signs_bg()
  local function apply()
    vim.api.nvim_set_hl(0, "SignColumn", { link = "Normal" })

    local function clear_bg(group)
      local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
      if hl.bg or hl.ctermbg then
        hl.bg = nil
        hl.ctermbg = nil
        vim.api.nvim_set_hl(0, group, hl)
      end
    end

    clear_bg("FoldColumn")
    clear_bg("LineNr")

    local sign_prefixes = {
      "GitSignsAdd",
      "GitSignsChange",
      "GitSignsDelete",
      "GitSignsChangedelete",
      "GitSignsTopdelete",
      "GitSignsUntracked",
    }

    for _, base in ipairs(sign_prefixes) do
      clear_bg(base)
      clear_bg(base .. "Nr")
      clear_bg(base .. "Cul")
      local staged = base:gsub("^GitSigns", "GitSignsStaged")
      clear_bg(staged)
      clear_bg(staged .. "Nr")
      clear_bg(staged .. "Cul")
    end
  end

  apply()
  vim.schedule(apply)
end

local signs_bg_group = vim.api.nvim_create_augroup("DynamicSignsBg", { clear = true })
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = signs_bg_group,
  callback = sync_signs_bg,
})

-- -- ── File Save Notification ──────────────────────────────────────────────────
-- vim.api.nvim_create_autocmd("BufWritePost", {
--   desc = "Notify when saving a file",
--   callback = function(ev)
--     local filename = vim.fn.fnamemodify(ev.file, ":t")
--     vim.notify("Saved " .. filename, vim.log.levels.INFO, { title = "Buffer Saved" })
--   end,
-- })

-- ── Auto Filetype & Treesitter Detection ──────────────────────────────────
vim.api.nvim_create_autocmd("BufWritePost", {
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
  vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
    group = tmux_group,
    callback = function()
      vim.system({ "tmux", "set", "status", "off" })
    end,
  })
  vim.api.nvim_create_autocmd({ "VimLeave", "VimSuspend" }, {
    group = tmux_group,
    callback = function()
      vim.system({ "tmux", "set", "status", "on" })
    end,
  })
end

vim.api.nvim_create_autocmd("SessionLoadPost", {
  desc = "Reattach treesitter highlighting on session restore",
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
        pcall(vim.treesitter.start, buf)
      end
    end
  end,
})
local number_toggle_group = vim.api.nvim_create_augroup("NumberToggle", { clear = true })

-- Switch to absolute line numbers on entering Insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  group = number_toggle_group,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
    end
  end,
})

-- Restore relative line numbers on leaving Insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  group = number_toggle_group,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = true
    end
  end,
})

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
})
