local cached_tmux_windows = ""
local function update_tmux_windows()
  if not vim.env.TMUX then
    return
  end
  vim.system(
    { "tmux", "list-windows", "-F", "#{window_name}|#{window_active}|#{window_flags}" },
    { text = true },
    function(obj)
      if obj.code ~= 0 or not obj.stdout then
        return
      end
      local items = {}
      for line in obj.stdout:gmatch("[^\r\n]+") do
        local idx_name, active, flags = line:match("^(.-)|(.-)|(.*)$")
        if idx_name then
          local is_active = (active == "1")
          local is_zoomed = flags and flags:find("Z") ~= nil
          local tag = idx_name
          if is_zoomed then
            tag = tag .. " 󰍉"
          end
          if is_active then
            table.insert(items, tag .. "*")
          else
            table.insert(items, tag)
          end
        end
      end
      local result = table.concat(items, " ▪ ")
      if result ~= cached_tmux_windows then
        cached_tmux_windows = result
        vim.schedule(function()
          pcall(function()
            require("lualine").refresh({ place = { "statusline" } })
          end)
        end)
      end
    end
  )
end

if vim.env.TMUX then
  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained", "VimResume", "TermClose" }, {
    callback = update_tmux_windows,
  })
end
local cmdline_notif_win = nil
local cmdline_notif_buf = nil
local cmdline_notif_timer = nil

local function close_cmdline_notification()
  if cmdline_notif_timer then
    cmdline_notif_timer:stop()
  end
  if cmdline_notif_win and vim.api.nvim_win_is_valid(cmdline_notif_win) then
    vim.api.nvim_win_close(cmdline_notif_win, true)
    cmdline_notif_win = nil
  end
end

local function add_to_noice_history(str, level)
  local ok_msg, Message = pcall(require, "noice.message")
  local ok_mgr, Manager = pcall(require, "noice.message.manager")
  if ok_msg and ok_mgr then
    local lvl_map = {
      [vim.log.levels.ERROR] = "error",
      [vim.log.levels.WARN] = "warn",
      [vim.log.levels.INFO] = "info",
      [vim.log.levels.DEBUG] = "debug",
      [vim.log.levels.TRACE] = "trace",
    }
    local kind = type(level) == "number" and (lvl_map[level] or "info") or (level or "info")
    local m = Message("notify", kind, str)
    if kind == "error" then
      m.level = "error"
    elseif kind == "warn" then
      m.level = "warn"
    end
    Manager._history[m.id] = m
  end
end

local function show_cmdline_notification(msg, level)
  close_cmdline_notification()

  local str = type(msg) == "string" and msg or vim.inspect(msg)
  str = str:gsub("[\r\n]+", " "):gsub("%s+", " ")
  if str == "" then
    return
  end

  add_to_noice_history(str, level)

  if not cmdline_notif_buf or not vim.api.nvim_buf_is_valid(cmdline_notif_buf) then
    cmdline_notif_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[cmdline_notif_buf].bufhidden = "wipe"
  end

  vim.api.nvim_buf_set_lines(cmdline_notif_buf, 0, -1, false, { str })

  local width = math.max(#str, 1)
  local row = math.max(vim.o.lines - 2, 0)

  cmdline_notif_win = vim.api.nvim_open_win(cmdline_notif_buf, false, {
    relative = "editor",
    row = row,
    col = 0,
    width = width,
    height = 1,
    style = "minimal",
    border = "none",
    focusable = false,
    noautocmd = true,
  })

  vim.wo[cmdline_notif_win].winhighlight = "Normal:Normal,NormalFloat:Normal"

  cmdline_notif_timer = vim.uv.new_timer()
  cmdline_notif_timer:start(
    2500,
    0,
    vim.schedule_wrap(function()
      close_cmdline_notification()
    end)
  )
end

vim.api.nvim_create_autocmd({ "CmdlineEnter", "InsertEnter" }, {
  desc = "Dismiss cmdline notification on user input",
  callback = close_cmdline_notification,
})

vim.notify = function(msg, level)
  show_cmdline_notification(msg, level)
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("cmdline_write_notify", { clear = true }),
  desc = "Display written notification on cmdline row",
  callback = function(ev)
    if not vim.api.nvim_buf_is_valid(ev.buf) or ev.file == "" then
      return
    end
    local filename = vim.fn.fnamemodify(ev.file, ":~:.")
    if filename == "" then
      filename = vim.fn.fnamemodify(ev.file, ":t")
    end
    local lines = vim.api.nvim_buf_line_count(ev.buf)
    local stat = vim.uv.fs_stat(ev.file)
    local bytes = stat and stat.size or vim.fn.getfsize(ev.file)
    vim.schedule(function()
      show_cmdline_notification(string.format('"%s" %dL, %dB written', filename, lines, bytes))
    end)
  end,
})

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
        lualine_a = {
          {
            "mode",
            fmt = function(str)
              return str:sub(1, 1)
            end,
          },
        },
        lualine_b = { { "filename", path = 1 } },
        lualine_c = { "branch", "diff", "diagnostics" },
        lualine_x = {
          {
            function()
              return vim.lsp.status()
            end,
            "encoding",
            "fileformat",
            "filetype",
          },
          {
            function()
              return cached_tmux_windows
            end,
            cond = function()
              return vim.env.TMUX ~= nil and cached_tmux_windows ~= ""
            end,
          },
        },
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
    },
    opts = {
      lsp = {
        progress = {
          enabled = false,
        }
      },
      notify = {
        enabled = false,
      },
      messages = {
        enabled = true,
        view = "mini",
        view_error = "mini",
        view_warn = "mini",
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            find = "written",
          },
          opts = { skip = true },
        },
      },
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
        confirm = {
          backend = "popup",
          relative = "editor",
          position = {
            row = -1,
            col = 0,
          },
          size = {
            width = "auto",
            height = "auto",
          },
          border = {
            style = "none",
          },
          win_options = {
            winhighlight = "NormalFloat:Normal,FloatBorder:Normal,FloatTitle:Normal,MsgArea:Normal",
          },
        },
        mini = {
          backend = "mini",
          relative = "editor",
          align = "message-left",
          timeout = 2500,
          position = {
            row = -1,
            col = 0,
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
  -- {
  --   "brenoprata10/nvim-highlight-colors",
  --   opts = {
  --     render = "background",
  --     enable_named_colors = false,
  --     enable_tailwind = false,
  --   },
  -- },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
    config = function()
      local hl_groups = {
        "DashboardHeader",
        "DashboardCenter",
        "DashboardShortcut",
        "DashboardKey",
        "DashboardDesc",
        "DashboardIcon",
        "DashboardFiles",
        "DashboardMruTitle",
        "DashboardProjectTitle",
      }
      for _, group in ipairs(hl_groups) do
        vim.api.nvim_set_hl(0, group, { link = "Normal" })
      end

      local v = vim.version()
      local version_str = string.format("nvim v%d.%d.%d", v.major, v.minor, v.patch)

      local shortcuts = {
        {
          desc = "insert",
          group = "Normal",
          action = "ene | startinsert",
          key = "i",
        },
        {
          desc = "config",
          group = "Normal",
          action = "lua require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })",
          key = "c",
        },
        {
          desc = "quit",
          group = "Normal",
          action = "q",
          key = "q",
        },
      }

      if package.loaded.lazy ~= nil or vim.fn.exists(":Lazy") == 2 then
        table.insert(shortcuts, 2, {
          desc = "lazy",
          group = "Normal",
          action = "Lazy",
          key = "l",
        })
      end

      if package.loaded.mason ~= nil or vim.fn.exists(":Mason") == 2 then
        table.insert(shortcuts, 2, {
          desc = "mason",
          group = "Normal",
          action = "Mason",
          key = "m",
        })
      end
      require("dashboard").setup({
        theme = "hyper",
        config = {
          week_header = {
            enable = false,
          },
          header = {
            "",
            version_str,
            "",
          },
          shortcut = shortcuts,
          mru = {
            limit = 5,
            icon = " ",
            label = " ",
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
