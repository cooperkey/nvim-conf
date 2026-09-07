local function ensure_ssh_agent()
  local sock = vim.fn.expand("~/.ssh/ssh-agent.sock")
  if vim.uv.fs_stat(sock) then
    vim.env.SSH_AUTH_SOCK = sock
  end
end

ensure_ssh_agent()

local function add_ssh_key()
  ensure_ssh_agent()
  local sock = vim.env.SSH_AUTH_SOCK or vim.fn.expand("~/.ssh/ssh-agent.sock")
  if not vim.uv.fs_stat(sock) then
    vim.notify("SSH agent socket not found: " .. sock, vim.log.levels.ERROR)
    return
  end

  local key_path = vim.fn.expand("~/.ssh/id_ed25519")
  if not vim.uv.fs_stat(key_path) then
    vim.notify("SSH private key not found: " .. key_path, vim.log.levels.ERROR)
    return
  end

  local check = vim.system({ "ssh-add", "-l" }, { env = { SSH_AUTH_SOCK = sock }, text = true }):wait()
  if check.code == 0 and check.stdout and check.stdout:find("id_ed25519") then
    vim.notify("SSH key is already loaded in agent")
    return
  end

  local pass = vim.fn.inputsecret("Enter passphrase for " .. key_path .. ": ")
  if not pass or pass == "" then
    vim.notify("SSHAdd: cancelled")
    return
  end

  local askpass = vim.fn.stdpath("data") .. "/ssh_askpass.sh"
  if not vim.uv.fs_stat(askpass) then
    local f = io.open(askpass, "w")
    if f then
      f:write("#!/bin/sh\nif [ -f \"$SSH_PASS_FILE\" ]; then\n  cat \"$SSH_PASS_FILE\"\n  rm -f \"$SSH_PASS_FILE\"\nelse\n  exit 1\nfi\n")
      f:close()
      vim.uv.fs_chmod(askpass, 448)
    end
  end

  local pass_file = vim.fn.tempname()
  local pf = io.open(pass_file, "w")
  if pf then
    pf:write(pass .. "\n")
    pf:close()
    vim.uv.fs_chmod(pass_file, 384)
  end

  local res = vim.system({ "ssh-add", key_path }, {
    env = {
      SSH_AUTH_SOCK = sock,
      SSH_ASKPASS = askpass,
      SSH_ASKPASS_REQUIRE = "force",
      DISPLAY = ":0",
      SSH_PASS_FILE = pass_file,
    },
    stdin = false,
  }):wait()

  pcall(os.remove, pass_file)

  if res.code == 0 then
    vim.notify("Identity added: " .. key_path)
  else
    vim.notify("Failed to add SSH key: incorrect passphrase", vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_user_command("SSHAdd", add_ssh_key, { desc = "Add SSH key to agent using cmdline input" })

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
