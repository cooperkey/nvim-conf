return {
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gvdiffsplit",
      "Gedit",
      "Gsplit",
      "Gvsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "Glgrep",
      "Gclog",
      "GlLog",
      "GMove",
      "GDelete",
      "GBrowse",
    },
    keys = {
      {
        "<leader>gg",
        function()
          local dir = require("coop.util").get_context_dir()
          local root = vim.fs.root(dir, ".git")
          if root and vim.fn.exists("*FugitiveDetect") == 1 then
            vim.fn["FugitiveDetect"](root)
          end
          vim.cmd.Git()
        end,
        desc = "Open fugitive git panel",
      },
      {
        "<leader>gs",
        function()
          local dir = require("coop.util").get_context_dir()
          local root = vim.fs.root(dir, ".git")
          if root and vim.fn.exists("*FugitiveDetect") == 1 then
            vim.fn["FugitiveDetect"](root)
          end
          vim.cmd.Git()
        end,
        desc = "Open fugitive git panel",
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "▎" },
        delete = { text = "-" },
        topdelete = { text = "▎" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "+" },
        change = { text = "▎" },
        delete = { text = "-" },
        topdelete = { text = "▎" },
        changedelete = { text = "▎" },
      },
    },
  },
}
