local function ensure_ssh_agent()
  local sock = vim.fn.expand("~/.ssh/ssh-agent.sock")
  if vim.uv.fs_stat(sock) then
    vim.env.SSH_AUTH_SOCK = sock
  end
end

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
      "SSHAdd",
    },
    init = function()
      vim.api.nvim_create_user_command("SSHAdd", function()
        ensure_ssh_agent()
        vim.cmd("botright 10split | term ssh-add ~/.ssh/id_ed25519")
      end, { desc = "Add SSH key to agent" })
    end,
    keys = {
      {
        "<leader>gg",
        function()
          ensure_ssh_agent()
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
          ensure_ssh_agent()
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
