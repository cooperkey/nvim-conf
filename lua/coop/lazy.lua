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

local ok, custom = pcall(require, "coop.custom")
local custom_specs = (ok and type(custom.get_specs) == "function") and custom.get_specs() or {}

require("lazy").setup({
  { import = "coop.plugins" },
  custom_specs,
}, {
  change_detection = {
    notify = false,
  },
})

if ok and type(custom.setup) == "function" then
  custom.setup()
end
