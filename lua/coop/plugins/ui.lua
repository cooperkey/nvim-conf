return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        globalstatus = true,
        icons_enabled = true,
        theme = 'auto',
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { { 'mode', fmt = function(str) return str:sub(1,1) end } },
        lualine_b = { { 'filename', path = 1 } },
        lualine_c = { 'branch', 'diff', 'diagnostics' },
        lualine_x = {},
        lualine_y = { 'progress', 'location' },
        lualine_z = { function()
          return os.date(" %a %d %b  %H:%M")
        end },
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        opts = {
          top_down = false,
          stages = "static",
          timeout = 2000,
          render = "compact",
          max_width = 50,
          max_height = 10,
          fps = 60,
        },
      },
    },
    opts = {
      cmdline = {
        view = "cmdline",
      },
      views = {
        cmdline = {
          backend = "popup",
          relative = "editor",
          position = {
            row = -1,
            col = 0,
          },
          size = {
            width = "50%",
            height = "auto",
          },
          border = {
            style = "none",
          },
          win_options = {
            winhighlight = "NormalFloat:Normal",
          },
        },
      },
      popupmenu = {
        enabled = false,
      },
    },
  },
}
