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
local notif_stack = {}
local NOTIF_MAX = 3
_G._notif_history = {}
local NOTIF_HISTORY_MAX = 50

local function close_notif_slot(slot)
  if slot.timer then
    slot.timer:stop()
    slot.timer:close()
    slot.timer = nil
  end
  if slot.win and vim.api.nvim_win_is_valid(slot.win) then
    vim.api.nvim_win_close(slot.win, true)
    slot.win = nil
  end
  if slot.buf and vim.api.nvim_buf_is_valid(slot.buf) then
    pcall(vim.api.nvim_buf_delete, slot.buf, { force = true })
    slot.buf = nil
  end
end

local function reposition_stack()
  local bottom_row = vim.o.lines - 2
  for i = #notif_stack, 1, -1 do
    local slot = notif_stack[i]
    if slot.win and vim.api.nvim_win_is_valid(slot.win) then
      local row = math.max(bottom_row - slot.height + 1, 0)
      vim.api.nvim_win_set_config(slot.win, { relative = "editor", row = row, col = 0 })
      bottom_row = row - 1
    end
  end
end

local function remove_slot(slot)
  close_notif_slot(slot)
  for i, s in ipairs(notif_stack) do
    if s == slot then
      table.remove(notif_stack, i)
      break
    end
  end
  vim.schedule(reposition_stack)
end

local function close_all_notifications()
  for _, slot in ipairs(notif_stack) do
    close_notif_slot(slot)
  end
  notif_stack = {}
end

local function show_cmdline_notification(msg, level)
  local raw = type(msg) == "string" and msg or vim.inspect(msg)
  local is_multiline = raw:find("[\r\n]") ~= nil

  local lines, width
  if is_multiline then
    lines = {}
    width = 1
    for line in (raw .. "\n"):gmatch("([^\r\n]*)\r?\n") do
      lines[#lines + 1] = line
      if #line > width then
        width = #line
      end
    end
    while #lines > 0 and lines[#lines] == "" do
      lines[#lines] = nil
    end
  else
    local str = raw:gsub("%s+", " ")
    if str == "" then
      return
    end
    lines = { str }
    width = #str
  end

  if #lines == 0 then
    return
  end
  width = math.max(width, 1)

  -- Add to notification history (accessible via <leader>n)
  table.insert(_G._notif_history, 1, {
    msg = raw,
    level = level,
    time = os.time(),
  })
  if #_G._notif_history > NOTIF_HISTORY_MAX then
    _G._notif_history[#_G._notif_history] = nil
  end

  -- If user is actively typing in the cmdline, don't popup over it
  if vim.fn.getcmdtype() ~= "" or vim.api.nvim_get_mode().mode == "c" then
    return
  end

  -- evict oldest if stack full
  if #notif_stack >= NOTIF_MAX then
    remove_slot(notif_stack[1])
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local height = #lines
  local row = math.max(vim.o.lines - 1 - height, 0)

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    row = row,
    col = 0,
    width = width,
    height = height,
    style = "minimal",
    border = "none",
    focusable = false,
    noautocmd = true,
  })
  vim.wo[win].winhighlight = "Normal:Normal,NormalFloat:Normal"

  local slot = { win = win, buf = buf, height = height, timer = vim.uv.new_timer() }
  notif_stack[#notif_stack + 1] = slot

  reposition_stack()

  slot.timer:start(
    2500,
    0,
    vim.schedule_wrap(function()
      remove_slot(slot)
    end)
  )
end

vim.api.nvim_create_autocmd({ "CmdlineEnter", "InsertEnter", "CmdwinEnter" }, {
  desc = "Dismiss cmdline notification on user input or entering cmdline",
  callback = close_all_notifications,
})

vim.api.nvim_create_autocmd("VimResized", {
  desc = "Reposition cmdline notifications on resize",
  callback = function()
    vim.schedule(reposition_stack)
  end,
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
        },
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
  {
    "brenoprata10/nvim-highlight-colors",
    opts = {
      render = "background",
      enable_named_colors = false,
      enable_tailwind = false,
    },
  },
  {
    "custom-dashboard",
    virtual = true,
    config = function()
      local function get_stats()
        local ok_lazy, lazy = pcall(require, "lazy")
        if ok_lazy and lazy.stats then
          local s = lazy.stats()
          local ms = s.startuptime
          if not ms or ms == 0 then
            if s.times and s.times.LazyDone and s.times.LazyStart then
              ms = math.floor((s.times.LazyDone - s.times.LazyStart) * 100 + 0.5) / 100
            else
              ms = math.floor((vim.uv.hrtime() / 1e6) * 100 + 0.5) / 100
            end
          else
            ms = math.floor(ms * 100 + 0.5) / 100
          end
          return ms, s.loaded or 0, s.count or 0
        end
        return nil, 0, 0
      end

      local function create_dashboard()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_current_buf(buf)

        local v = vim.version()
        local ver = string.format("nvim v%d.%d.%d", v.major, v.minor, v.patch)

        local shortcuts = {
          { key = "i", label = "insert", cmd = "ene | startinsert" },
          { key = "c", label = "config", cmd = "lua require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })" },
          { key = "q", label = "quit",   cmd = "q" },
        }
        if package.loaded.lazy ~= nil or vim.fn.exists(":Lazy") == 2 then
          table.insert(shortcuts, 2, { key = "l", label = "lazy", cmd = "Lazy" })
        end
        if package.loaded.mason ~= nil or vim.fn.exists(":Mason") == 2 or vim.fn.isdirectory(vim.fn.stdpath("data") .. "/mason") == 1 then
          table.insert(shortcuts, 2, { key = "m", label = "mason", cmd = "Mason" })
        end

        local cwd = vim.fn.getcwd() .. "/"
        local mru = {}
        for _, f in ipairs(vim.v.oldfiles or {}) do
          if #mru >= 5 then break end
          local full = vim.fn.fnamemodify(f, ":p")
          if full:sub(1, #cwd) == cwd and vim.fn.filereadable(full) == 1 then
            mru[#mru + 1] = vim.fn.fnamemodify(f, ":~:.")
          end
        end

        local content = {
          ver,
          "",
        }

        local bar = {}
        for _, s in ipairs(shortcuts) do
          bar[#bar + 1] = s.label .. "  " .. s.key
        end
        content[#content + 1] = table.concat(bar, "    ")
        content[#content + 1] = ""

        if #mru > 0 then
          content[#content + 1] = "recent_files"
          content[#content + 1] = ""
          for _, f in ipairs(mru) do
            content[#content + 1] = "  " .. f
          end
          content[#content + 1] = ""
        end

        local ms, loaded, count = get_stats()
        if ms then
          content[#content + 1] = string.format("Startuptime: %.2f ms", ms)
          content[#content + 1] = string.format("Plugins: %d loaded / %d installed", loaded, count)
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
        vim.bo[buf].modifiable = false
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].swapfile = false
        vim.bo[buf].filetype = "dashboard"

        vim.opt_local.number = true
        vim.opt_local.relativenumber = true
        vim.opt_local.cursorline = true
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"

        for _, s in ipairs(shortcuts) do
          vim.keymap.set("n", s.key, "<cmd>" .. s.cmd .. "<cr>", { buffer = buf, nowait = true, silent = true })
        end

        vim.keymap.set("n", "<CR>", function()
          local line = vim.trim(vim.api.nvim_get_current_line())
          if line ~= "" and (vim.fn.filereadable(line) == 1 or vim.fn.filereadable(vim.fn.expand(line)) == 1) then
            vim.cmd("edit " .. vim.fn.fnameescape(line))
          end
        end, { buffer = buf, silent = true })

        vim.api.nvim_create_autocmd("User", {
          pattern = "LazyVimStarted",
          once = true,
          callback = function()
            if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "dashboard" then
              local accurate_ms, l, c = get_stats()
              if accurate_ms then
                local line_count = vim.api.nvim_buf_line_count(buf)
                local new_lines = {
                  string.format("Startuptime: %.2f ms", accurate_ms),
                  string.format("Plugins: %d loaded / %d installed", l, c),
                }
                vim.bo[buf].modifiable = true
                vim.api.nvim_buf_set_lines(buf, math.max(line_count - 2, 0), line_count, false, new_lines)
                vim.bo[buf].modifiable = false
              end
            end
          end,
        })
      end

      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" and not vim.bo.modified then
            create_dashboard()
          end
        end,
      })

      vim.api.nvim_create_user_command("Dashboard", create_dashboard, { desc = "Show dashboard" })
    end,
  },
}
