return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true,
      columns = {},
      skip_confirm_for_simple_edits = true,
      use_default_keymaps = false,
      keymaps = {
        ["<CR>"]    = "actions.select",
        ["<Right>"] = "actions.select",
        ["<Left>"]  = "actions.parent",
        ["<->"]     = "actions.parent",
        ["<_>"]     = "actions.open_cwd",
        ["g."]      = "actions.toggle_hidden",
        ["<C-p>"]   = "actions.preview",
        ["<C-r>"]   = "actions.refresh",
        ["gx"]      = "actions.open_external",
        ["g?"]      = "actions.show_help",
        ["q"]       = "actions.close",
        ["<Esc>"]   = "actions.close",
      },
      view_options = {
        show_hidden = true,
        natural_order = true,
      },
      float = {
        padding = 2,
        max_width = 90,
        max_height = 35,
        win_options = {
          winblend = 5,
        },
      },
    },
  },
}
