return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      {
        "<leader><leader>",
        function()
          local dir = require("coop.util").get_context_dir()
          require("telescope.builtin").find_files({ cwd = dir })
        end,
        desc = "Open telescope",
      },
      {
        "<C-p>",
        function()
          local dir = require("coop.util").get_context_dir()
          require("telescope.builtin").git_files({ cwd = dir })
        end,
        desc = "Open git files",
      },
      {
        "<leader>/",
        function()
          local dir = require("coop.util").get_context_dir()
          require("telescope.builtin").live_grep({ cwd = dir })
        end,
        desc = "Live grep search",
      },
      {
        "<leader>gw",
        function()
          local dir = require("coop.util").get_context_dir()
          require("telescope.builtin").grep_string({ cwd = dir })
        end,
        desc = "Grep word under cursor",
      },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = {
          width = 0.90,
          height = 0.85,
          preview_width = 0.65,
          prompt_position = "top",
        },
        sorting_strategy = "ascending",
        mappings = {
          i = {
            ["<Esc>"] = function(...)
              return require("telescope.actions").close(...)
            end,
          },
        },
      },
      pickers = {
        grep_string = {
          layout_config = {
            preview_width = 0.60,
          },
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "notify")
      pcall(telescope.load_extension, "noice")
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
