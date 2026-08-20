local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local custom_path = vim.fn.expand("~/.config/custom/current/theme/neovim.lua")
local has_custom = vim.uv.fs_stat(custom_path) ~= nil
local custom = has_custom and require("coop.custom") or nil

require("lazy").setup({
  { import = "coop.plugins" },
  has_custom and custom.get_specs() or {},
})

if has_custom then
  custom.setup()
end
