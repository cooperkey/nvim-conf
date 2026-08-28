return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        globalstatus = true,
        icons_enabled = true,
        theme = "auto",
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { {
          "mode",
          fmt = function(str)
            return str:sub(1, 1)
          end,
        } },
        lualine_b = { { "filename", path = 1 } },
        lualine_c = { "branch", "diff", "diagnostics" },
        lualine_x = {},
        lualine_y = { "progress" },
        lualine_z = {
          function()
            return os.date("%a %d %b %H:%M")
          end,
        },
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
            width = "30%",
            height = "auto",
          },
          border = {
            style = "none",
          },
          win_options = {
            winhighlight = "NormalFloat:Normal,FloatBorder:Normal,FloatTitle:Normal,MsgArea:Normal",
          },
        },
      },
      popupmenu = {
        enabled = false,
      },
    },
  },
  {
    "brenoprata10/nvim-highlight-colors",
    opts = {},
  },
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
    config = function()
      local hl_groups = {
        'DashboardHeader',
        'DashboardCenter',
        'DashboardShortcut',
        'DashboardKey',
        'DashboardDesc',
        'DashboardIcon',
        'DashboardFiles',
        'DashboardMruTitle',
        'DashboardProjectTitle',
      }
      for _, group in ipairs(hl_groups) do
        vim.api.nvim_set_hl(0, group, { link = 'Normal' })
      end

      local v = vim.version()
      local version_str = string.format('nvim v%d.%d.%d', v.major, v.minor, v.patch)

      local shortcuts = {
        {
          desc = 'insert',
          group = 'Normal',
          action = 'ene | startinsert',
          key = 'i',
        },
        {
          desc = 'config',
          group = 'Normal',
          action = "lua require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })",
          key = 'c',
        },
        {
          desc = 'quit',
          group = 'Normal',
          action = 'q',
          key = 'q',
        },
      }

      if package.loaded.lazy ~= nil or vim.fn.exists(':Lazy') == 2 then
        table.insert(shortcuts, 2, {
          desc = 'lazy',
          group = 'Normal',
          action = 'Lazy',
          key = 'l',
        })
      end

      if package.loaded.mason ~= nil or vim.fn.exists(':Mason') == 2 then
        table.insert(shortcuts, 2, {
          desc = 'mason',
          group = 'Normal',
          action = 'Mason',
          key = 'm',
        })
      end
      require('dashboard').setup({
        theme = 'hyper',
        config = {
          week_header = {
            enable = false,
          },
          header = {
            '',
            version_str,
            '',
          },
          shortcut = shortcuts,
          mru = {
            limit = 5,
            icon = ' ',
            label = ' ',
            cwd_only = true,
          },
          project = {
            enable = false,
          },
          footer = {},
        },
      })
    end,
  },
}
