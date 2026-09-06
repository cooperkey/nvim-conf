return {
  {
    "termux-dynamic-colorscheme",
    virtual = true,
    priority = 1000,
    config = function()
      vim.opt.background = "dark"
      pcall(vim.cmd.colorscheme, "gruvbox")
    end,
  },
}
