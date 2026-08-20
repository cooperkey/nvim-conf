return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      {
        "<leader><leader>",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "Open telescope",
      },
      {
        "<C-p>",
        function()
          require("telescope.builtin").git_files()
        end,
        desc = "Open git files",
      },
      {
        "<leader>/",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep search",
      },
      {
        "<leader>gw",
        function()
          require("telescope.builtin").grep_string()
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
