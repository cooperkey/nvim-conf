local M = {}

local is_android = (vim.fn.has("android") == 1)
  or (vim.env.PREFIX ~= nil and vim.env.PREFIX:find("com%.termux") ~= nil)

M.is_android = is_android

M.config = {
  focus_lost_timeout = is_android and 180000 or 1800000, -- 3 min on Termux/Android, 30 min on Desktop (ms)
  idle_timeout = is_android and 480000 or 3600000,       -- 8 min on Termux/Android, 60 min on Desktop (ms)
  orphan_debounce = is_android and 15000 or 60000,      -- 15s on Termux/Android, 60s on Desktop (ms)
  suspend_compilers = is_android,                       -- Freeze terminal jobs only on Termux/Android
  stop_preview = true,                                  -- Stop background markdown-preview HTTP server
  notify = true,                                        -- Notify on state transitions
}

local state = {
  is_suspended = false,
  suspended_reason = nil,
  suspended_jobs = {},         -- map of pid -> { bufnr, job_id, name }
  last_active_time = 0,
  focus_timer = nil,
  idle_timer = nil,
  orphan_timer = nil,
  has_focus = true,
}

---Get resident memory (VmRSS) in KB from /proc/<pid>/status on Linux/Android.
---@param pid number
---@return number|nil
local function get_proc_rss_kb(pid)
  if not pid or pid <= 0 then
    return nil
  end
  local f = io.open("/proc/" .. pid .. "/status", "r")
  if not f then
    return nil
  end
  local rss = nil
  for line in f:lines() do
    local val = line:match("^VmRSS:%s+(%d+)%s+kB")
    if val then
      rss = tonumber(val)
      break
    end
  end
  f:close()
  return rss
end

---Get all child PIDs of Neovim.
---@return number[]
local function get_child_pids()
  local my_pid = vim.fn.getpid()
  local pids = {}

  -- Fast path on Linux: read procfs children node directly without subshell
  local cf = io.open("/proc/" .. my_pid .. "/task/" .. my_pid .. "/children", "r")
  if cf then
    local content = cf:read("*a")
    cf:close()
    if content and content ~= "" then
      for pid_str in content:gmatch("%S+") do
        local pid = tonumber(pid_str)
        if pid then
          table.insert(pids, pid)
        end
      end
      return pids
    end
  end

  -- Fallback for Android/Termux or environments without task children node
  local p = io.popen("pgrep -P " .. my_pid .. " 2>/dev/null")
  if p then
    for line in p:lines() do
      local pid = tonumber(line)
      if pid then
        table.insert(pids, pid)
      end
    end
    p:close()
  end
  return pids
end

---Find PID for a given LSP client by matching binary name in child process cmdlines.
---@param client table
---@param child_pids number[]
---@return number|nil
local function find_client_pid(client, child_pids)
  local cmd_bin = client.config and client.config.cmd and client.config.cmd[1] or client.name
  local base_bin = vim.fs.basename(cmd_bin)
  for _, cpid in ipairs(child_pids) do
    local cf = io.open("/proc/" .. cpid .. "/cmdline", "r")
    if cf then
      local raw = cf:read("*a") or ""
      cf:close()
      if raw:find(base_bin, 1, true) or (client.name and raw:find(client.name, 1, true)) then
        return cpid
      end
    end
  end
  return nil
end

---Check if a filetype has an enabled LSP server in Neovim's registered configs.
---@param filetype string
---@return boolean
local function has_enabled_lsp_for_ft(filetype)
  if not filetype or filetype == "" then
    return false
  end
  -- Neovim 0.12+ public API
  if vim.lsp.get_configs then
    local configs = vim.lsp.get_configs({ enabled = true, filetype = filetype })
    if configs and #configs > 0 then
      return true
    end
  end
  -- Fallback for Neovim 0.10/0.11 or internal table
  if vim.lsp and vim.lsp.config and vim.lsp.config._configs then
    for name, cfg in pairs(vim.lsp.config._configs) do
      if vim.lsp.is_enabled and vim.lsp.is_enabled(name) then
        local fts = cfg.filetypes or (cfg.config and cfg.config.filetypes)
        if fts then
          for _, ft in ipairs(fts) do
            if ft == filetype then
              return true
            end
          end
        end
      end
    end
  end
  return false
end

---Get active, unstopped LSP clients.
---@return table[]
function M.get_active_lsp_clients()
  local active = {}
  for _, client in ipairs(vim.lsp.get_clients()) do
    if not client:is_stopped() then
      table.insert(active, client)
    end
  end
  return active
end

---Get list of valid, loaded, buflisted or visible buffer numbers attached to an LSP client.
---@param client table
---@return number[]
function M.get_valid_attached_buffers(client)
  local bufs = {}
  for bufnr, _ in pairs(client.attached_buffers or {}) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
      if vim.bo[bufnr].buflisted or vim.fn.bufwinid(bufnr) ~= -1 then
        table.insert(bufs, bufnr)
      end
    end
  end
  return bufs
end

---Check and stop any LSP client that has 0 valid buffers attached.
function M.check_orphan_clients()
  if state.is_suspended then
    return
  end
  local clients = M.get_active_lsp_clients()
  for _, client in ipairs(clients) do
    if client.initialized then
      local valid_bufs = M.get_valid_attached_buffers(client)
      if #valid_bufs == 0 and not client:is_stopped() then
        client:stop()
        if M.config.notify then
          vim.notify(
            string.format("[Resource Manager] Stopped orphan LSP client: %s (0 active buffers)", client.name),
            vim.log.levels.INFO
          )
        end
      end
    end
  end
end

---Debounce orphan LSP check.
local function schedule_orphan_check()
  if not state.orphan_timer then
    return
  end
  state.orphan_timer:stop()
  state.orphan_timer:start(
    M.config.orphan_debounce,
    0,
    vim.schedule_wrap(function()
      M.check_orphan_clients()
    end)
  )
end

---Get list of active terminal jobs inside Neovim.
---@return table[]
function M.get_active_terminal_jobs()
  local jobs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      local job_id = vim.b[buf].terminal_job_id
      if job_id then
        local pid = vim.fn.jobpid(job_id)
        if pid and pid > 0 then
          local buf_name = vim.api.nvim_buf_get_name(buf)
          table.insert(jobs, {
            bufnr = buf,
            job_id = job_id,
            pid = pid,
            name = vim.fs.basename(buf_name) ~= "" and vim.fs.basename(buf_name) or "terminal",
          })
        end
      end
    end
  end
  return jobs
end

---Trigger LSP re-attach for a buffer via FileType autocommand.
---@param bufnr number|nil
function M.resume_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end
  local buftype = vim.bo[bufnr].buftype
  if buftype ~= "" then
    return
  end
  local ft = vim.bo[bufnr].filetype
  if ft and ft ~= "" then
    vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr, modeline = false })
  end
end

---Suspend all LSP clients and freeze background terminal / compiler jobs.
---@param reason string|nil e.g. "idle", "focus_lost", "manual"
function M.suspend(reason)
  reason = reason or "manual"
  state.is_suspended = true
  state.suspended_reason = reason

  -- Stop all active LSP clients to release memory and CPU
  local stopped_lsp_count = 0
  for _, client in ipairs(M.get_active_lsp_clients()) do
    client:stop()
    stopped_lsp_count = stopped_lsp_count + 1
  end

  -- Freeze active terminal / compiler jobs via SIGSTOP
  local frozen_jobs_count = 0
  if M.config.suspend_compilers then
    for _, job in ipairs(M.get_active_terminal_jobs()) do
      if job.pid and job.pid > 0 and not state.suspended_jobs[job.pid] then
        -- Signal entire process group first (-pid), fallback to single process
        local ok = vim.uv.kill(-job.pid, "sigstop")
        if ok ~= 0 then
          vim.uv.kill(job.pid, "sigstop")
        end
        state.suspended_jobs[job.pid] = job
        frozen_jobs_count = frozen_jobs_count + 1
      end
    end
  end

  -- Stop background HTTP markdown preview server if active
  if M.config.stop_preview then
    pcall(vim.cmd, "MarkdownPreviewStop")
  end

  -- Stop prettierd daemon if installed
  if vim.fn.executable("prettierd") == 1 then
    pcall(vim.fn.jobstart, { "prettierd", "stop" }, { detach = true })
  end

  if M.config.notify and (reason == "manual" or stopped_lsp_count > 0 or frozen_jobs_count > 0) then
    vim.notify(
      string.format(
        "[Resource Manager] Suspended: %d LSP(s) stopped, %d job(s) frozen (%s)",
        stopped_lsp_count,
        frozen_jobs_count,
        reason
      ),
      vim.log.levels.INFO
    )
  end
end

---Resume LSP for current buffer and unfreeze suspended jobs.
---@param reason string|nil e.g. "activity", "focus_gained", "buf_enter", "manual"
function M.resume(reason)
  reason = reason or "manual"

  -- Cancel pending focus suspension timer
  if state.focus_timer then
    state.focus_timer:stop()
  end

  -- Unfreeze suspended terminal / compiler jobs via SIGCONT
  local resumed_jobs_count = 0
  for pid, _ in pairs(state.suspended_jobs) do
    local ok = vim.uv.kill(-pid, "sigcont")
    if ok ~= 0 then
      vim.uv.kill(pid, "sigcont")
    end
    resumed_jobs_count = resumed_jobs_count + 1
  end
  state.suspended_jobs = {}

  local was_suspended = state.is_suspended
  state.is_suspended = false
  state.suspended_reason = nil

  -- Re-attach LSP for all currently visible buffers across open windows
  local seen = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if not seen[buf] then
        seen[buf] = true
        M.resume_buffer(buf)
      end
    end
  end

  -- Reset idle timer
  state.last_active_time = vim.uv.now()
  M.reset_idle_timer()

  if M.config.notify and (reason == "manual" or was_suspended) then
    vim.notify(
      string.format("[Resource Manager] Resumed: visible buffers reattached, %d job(s) unfrozen", resumed_jobs_count),
      vim.log.levels.INFO
    )
  end
end

---Toggle suspend/resume manually.
function M.toggle_suspend()
  if state.is_suspended then
    M.resume("manual")
  else
    M.suspend("manual")
  end
end

---Reset idle countdown timer.
function M.reset_idle_timer()
  if not state.idle_timer then
    return
  end
  state.idle_timer:stop()
  state.idle_timer:start(
    M.config.idle_timeout,
    0,
    vim.schedule_wrap(function()
      M.suspend("idle")
    end)
  )
end

---Display floating window with complete resource manager status.
function M.show_status()
  local lines = {}
  local env_str = is_android and "Termux (Android)" or "Desktop (Linux)"
  table.insert(lines, "Antigravity Resource Manager")
  table.insert(lines, string.format("Environment: %s", env_str))
  table.insert(lines, string.rep("─", 50))

  -- Overall State
  local state_str = state.is_suspended
      and string.format("State: SUSPENDED (Reason: %s)", state.suspended_reason or "unknown")
    or "State: ACTIVE"
  table.insert(lines, state_str)

  -- Timers & Focus
  local now = vim.uv.now()
  local idle_elapsed = math.floor((now - state.last_active_time) / 1000)
  local idle_limit = math.floor(M.config.idle_timeout / 1000)
  local focus_str = state.has_focus and "Focused" or "Lost (timer running)"
  table.insert(lines, string.format("Focus: %s", focus_str))
  table.insert(lines, string.format("Idle Elapsed: %ds / %ds limit", idle_elapsed, idle_limit))
  table.insert(lines, "")

  -- Running LSP servers
  local child_pids = get_child_pids()
  local active_clients = M.get_active_lsp_clients()
  table.insert(lines, string.format("Active LSP Servers (%d):", #active_clients))
  if #active_clients == 0 then
    table.insert(lines, "  (none running - memory fully freed)")
  else
    for _, client in ipairs(active_clients) do
      local pid = find_client_pid(client, child_pids)
      local mem_str = "N/A"
      if pid then
        local rss = get_proc_rss_kb(pid)
        if rss then
          mem_str = string.format("%.1f MB", rss / 1024)
        end
      end
      local pid_str = pid and tostring(pid) or "unknown"
      table.insert(lines, string.format("  • %s [PID: %s | RSS: %s]", client.name, pid_str, mem_str))
      local valid_bufs = M.get_valid_attached_buffers(client)
      if #valid_bufs == 0 then
        table.insert(lines, "    Attached buffers: none (orphan - will be stopped)")
      else
        local buf_names = {}
        for _, b in ipairs(valid_bufs) do
          local bname = vim.fs.basename(vim.api.nvim_buf_get_name(b))
          table.insert(buf_names, string.format("#%d (%s)", b, bname ~= "" and bname or "unnamed"))
        end
        table.insert(lines, "    Attached: " .. table.concat(buf_names, ", "))
      end
    end
  end
  table.insert(lines, "")

  -- Terminal & Compiler Jobs
  local term_jobs = M.get_active_terminal_jobs()
  table.insert(lines, string.format("Terminal / Compiler Tasks (%d):", #term_jobs))
  if #term_jobs == 0 then
    table.insert(lines, "  (no active terminal buffers)")
  else
    for _, job in ipairs(term_jobs) do
      local job_status = state.suspended_jobs[job.pid] and "FROZEN (SIGSTOP)" or "RUNNING"
      local rss = get_proc_rss_kb(job.pid)
      local mem_str = rss and string.format("%.1f MB", rss / 1024) or "N/A"
      table.insert(
        lines,
        string.format("  • Buf #%d: %s [PID: %d | Status: %s | RSS: %s]", job.bufnr, job.name, job.pid, job_status, mem_str)
      )
    end
  end
  table.insert(lines, "")

  -- Controls
  table.insert(lines, "Controls:")
  table.insert(lines, "  <leader>ts / <leader>ls : Toggle LSP suspend/resume")
  table.insert(lines, "  :LspSuspend             : Suspend all LSPs & freeze jobs")
  table.insert(lines, "  :LspResume              : Resume LSP & unfreeze jobs")
  table.insert(lines, "  :LspStatus              : Show this status panel")

  -- Render floating window
  local width = math.min(math.max(64, vim.o.columns - 6), 80)
  local height = math.min(#lines + 2, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Resource Manager Status ",
    title_pos = "center",
  })

  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true, nowait = true })
  vim.keymap.set("n", "<esc>", "<cmd>close<cr>", { buffer = buf, silent = true, nowait = true })
end

---Initialize the Resource Manager.
---@param user_opts table|nil
function M.setup(user_opts)
  if user_opts then
    M.config = vim.tbl_deep_extend("force", M.config, user_opts)
  end

  state.focus_timer = vim.uv.new_timer()
  state.idle_timer = vim.uv.new_timer()
  state.orphan_timer = vim.uv.new_timer()
  state.last_active_time = vim.uv.now()

  local group = vim.api.nvim_create_augroup("CoopResourceManager", { clear = true })

  -- Focus Lost: start 3-minute countdown to suspend
  vim.api.nvim_create_autocmd("FocusLost", {
    group = group,
    callback = function()
      state.has_focus = false
      if state.focus_timer then
        state.focus_timer:stop()
        state.focus_timer:start(
          M.config.focus_lost_timeout,
          0,
          vim.schedule_wrap(function()
            M.suspend("focus_lost")
          end)
        )
      end
    end,
  })

  -- Focus Gained: cancel pending suspend or resume if already suspended
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      state.has_focus = true
      if state.focus_timer then
        state.focus_timer:stop()
      end
      if state.is_suspended then
        M.resume("focus_gained")
      else
        state.last_active_time = vim.uv.now()
        M.reset_idle_timer()
      end
    end,
  })

  -- User Activity: lightweight throttle on cursor move / text edit
  local function on_activity()
    if state.is_suspended then
      M.resume("activity")
      return
    end
    local now = vim.uv.now()
    if now - state.last_active_time > 30000 then
      state.last_active_time = now
      M.reset_idle_timer()
    end
  end

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter", "TextChanged", "TextChangedI" }, {
    group = group,
    callback = on_activity,
  })

  -- Buffer Enter: resume if suspended, or attach LSP if buffer has no LSP client
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(ev)
      if state.is_suspended then
        M.resume("buf_enter")
        return
      end
      local buf = ev.buf
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].buflisted then
        local ft = vim.bo[buf].filetype
        if ft and ft ~= "" then
          local clients = vim.lsp.get_clients({ bufnr = buf })
          if #clients == 0 and has_enabled_lsp_for_ft(ft) then
            M.resume_buffer(buf)
          end
        end
      end
    end,
  })

  -- Buffer Delete/Unload: trigger debounced orphan LSP check
  vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload", "BufWipeout" }, {
    group = group,
    callback = schedule_orphan_check,
  })

  -- Vim Exit: clean up background processes
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      for pid, _ in pairs(state.suspended_jobs) do
        local ok = pcall(vim.uv.kill, -pid, "sigcont")
        if not ok or ok ~= 0 then
          pcall(vim.uv.kill, pid, "sigcont")
        end
      end
      for _, c in ipairs(M.get_active_lsp_clients()) do
        pcall(function()
          c:stop()
        end)
      end
    end,
  })

  -- Start initial idle timer
  M.reset_idle_timer()

  -- User Commands
  vim.api.nvim_create_user_command("LspSuspend", function()
    M.suspend("manual")
  end, { desc = "Suspend all active LSP clients and freeze background jobs" })

  vim.api.nvim_create_user_command("LspResume", function()
    M.resume("manual")
  end, { desc = "Resume LSP on active buffer and unfreeze background jobs" })

  vim.api.nvim_create_user_command("LspToggle", function()
    M.toggle_suspend()
  end, { desc = "Toggle LSP suspend/resume" })

  vim.api.nvim_create_user_command("LspStatus", function()
    M.show_status()
  end, { desc = "Show Antigravity Resource Manager status" })

  -- Keybindings
  vim.keymap.set("n", "<leader>ts", M.toggle_suspend, { desc = "Toggle LSP / Job suspend" })
  vim.keymap.set("n", "<leader>ls", M.toggle_suspend, { desc = "Toggle LSP / Job suspend" })
end

return M
