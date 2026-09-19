return {
  {
    "termux-dynamic-colorscheme",
    virtual = true,
    priority = 1000,
    config = function()
      vim.opt.background = "dark"
      pcall(vim.cmd.colorscheme, "kanagawa")
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local clear = { bg = "NONE" }
          vim.api.nvim_set_hl(0, "SignColumn", clear)
          vim.api.nvim_set_hl(0, "FoldColumn", clear)
          vim.api.nvim_set_hl(0, "LineNr", clear)
        end,
      })
    end,
  },
}
