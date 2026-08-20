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

local custom = require("coop.custom")

require("lazy").setup({
  { import = "coop.plugins" },
  custom.get_specs(),
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<Esc>"] = function(...)
              return require("telescope.actions").close(...)
            end,
          },
        },
      },
    },
  },
})

custom.setup()
