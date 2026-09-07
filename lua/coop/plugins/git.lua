local function interactive_git(action)
  action = action or "push"
  local dir = require("coop.util").get_context_dir()
  local root = vim.fs.root(dir, ".git") or dir

  local width = math.min(math.floor(vim.o.columns * 0.8), 80)
  local height = math.min(math.floor(vim.o.lines * 0.5), 16)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Git " .. action:sub(1, 1):upper() .. action:sub(2) .. " ",
    title_pos = "center",
  })

  vim.fn.termopen("git -C " .. vim.fn.shellescape(root) .. " " .. action, {
    on_exit = function(_, code)
      if code == 0 then
        vim.defer_fn(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(b) and vim.bo[b].filetype == "fugitive" then
              vim.api.nvim_buf_call(b, function()
                vim.cmd("edit")
              end)
            end
          end
        end, 500)
      else
        vim.keymap.set("n", "q", function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end, { buffer = buf, silent = true })
      end
    end,
  })
  vim.cmd("startinsert")
end

return {
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "GitPush",
      "GitPull",
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
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fugitive",
        callback = function(evt)
          vim.keymap.set("n", "gp", function()
            interactive_git("push")
          end, { buffer = evt.buf, desc = "Git push (interactive prompt)" })
          vim.keymap.set("n", "gP", function()
            interactive_git("pull")
          end, { buffer = evt.buf, desc = "Git pull (interactive prompt)" })
        end,
      })

      vim.api.nvim_create_user_command("GitPush", function()
        interactive_git("push")
      end, { desc = "Git push with interactive prompt" })

      vim.api.nvim_create_user_command("GitPull", function()
        interactive_git("pull")
      end, { desc = "Git pull with interactive prompt" })
    end,
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
      {
        "<leader>gp",
        function()
          interactive_git("push")
        end,
        desc = "Git push (interactive prompt)",
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
