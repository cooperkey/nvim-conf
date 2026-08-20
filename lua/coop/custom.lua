local M = {}

local theme_dir = vim.fn.expand("~/.config/custom/current")
local theme_file = vim.fn.expand("~/.config/custom/current/theme/neovim.lua")
local theme_name_file = vim.fn.expand("~/.config/custom/current/theme.name")

local last_loaded_theme = ""

-- Map theme/colorscheme names to installed colorschemes or aliases
local name_map = {
  ["osaka-jade"] = "osaka-jade",
  ["osaka-jade-v1"] = "osaka-jade",
  ["amberbyte"] = "amberbyte",
  ["tokyo-night"] = "tokyonight-night",
  ["tokyo-night-v1"] = "tokyonight-night",
  ["catppuccin-v1"] = "catppuccin",
  ["catppuccin-latte"] = "catppuccin-latte",
  ["catppuccin-latte-v1"] = "catppuccin-latte",
  ["gruvbox-v1"] = "gruvbox",
  ["nord-v1"] = "nordfox",
  ["rose-pine-v1"] = "rose-pine-dawn",
  ["matte-black-v1"] = "matteblack",
  ["flexoki-light-v1"] = "flexoki-light",
  ["ristretto"] = "monokai-pro-ristretto",
  ["ristretto-v1"] = "monokai-pro-ristretto",
}

function M.get_specs()
  local specs = {}
  if vim.uv.fs_stat(theme_file) then
    local chunk = loadfile(theme_file)
    if chunk then
      local ok, res = pcall(chunk)
      if ok and type(res) == "table" then
        for _, spec in ipairs(res) do
          if type(spec) == "table" then
            local name = spec[1] or spec.name or ""
            if not string.find(name, "LazyVim") then
              table.insert(specs, spec)
            end
          end
        end
      end
    end
  end
  return specs
end

function M.get_current_theme_name()
  if vim.uv.fs_stat(theme_name_file) then
    local f = io.open(theme_name_file, "r")
    if f then
      local name = f:read("*all")
      f:close()
      if name then
        return vim.trim(name)
      end
    end
  end
  return ""
end

function M.apply_theme()
  local applied = false

  if vim.uv.fs_stat(theme_file) then
    local theme_folder = vim.fn.expand("~/.config/custom/current/theme")
    local old_path = package.path
    package.path = theme_folder .. "/?.lua;" .. package.path

    local chunk = loadfile(theme_file)
    if chunk then
      local ok, spec_list = pcall(chunk)
      if ok and type(spec_list) == "table" then
        for _, spec in ipairs(spec_list) do
          if type(spec) == "table" then
            if type(spec.init) == "function" then
              pcall(spec.init)
            end

            local cs = nil
            if type(spec.opts) == "table" and spec.opts.colorscheme then
              cs = spec.opts.colorscheme
            elseif spec.colorscheme then
              cs = spec.colorscheme
            end

            if cs then
              if type(cs) == "string" then
                local mapped = name_map[cs] or cs
                local cs_ok = pcall(vim.cmd.colorscheme, mapped)
                if not cs_ok then
                  local base_cs = cs:match("^([%w_]+)")
                  if base_cs then
                    pcall(vim.cmd.colorscheme, base_cs)
                  end
                end
                applied = true
              elseif type(cs) == "function" then
                pcall(cs)
                applied = true
              end
            end

            if type(spec.config) == "function" then
              pcall(spec.config)
            end
          end
        end
      end
    end
    package.path = old_path
  end

  if not applied then
    local tname = M.get_current_theme_name()
    if tname ~= "" then
      local mapped = name_map[tname] or tname
      pcall(vim.cmd.colorscheme, mapped)
    end
  end

  if package.loaded["lualine"] then
    pcall(function()
      require("lualine").setup({
        options = {
          theme = "auto",
        },
      })
    end)
  end

  last_loaded_theme = M.get_current_theme_name()
end

-- Hot-reload setup using vim.uv.new_fs_event
function M.setup()
  M.apply_theme()

  vim.api.nvim_create_user_command("CustomSync", function()
    M.apply_theme()
    vim.notify("Custom theme synced", vim.log.levels.INFO)
  end, { desc = "Sync Neovim theme with Custom" })

  if not vim.uv.fs_stat(theme_dir) then
    return
  end

  local timer = vim.uv.new_timer()
  local watcher = vim.uv.new_fs_event()

  watcher:start(
    theme_dir,
    { recursive = true },
    vim.schedule_wrap(function(err, filename, events)
      if err then
        return
      end
      timer:stop()
      timer:start(
        150,
        0,
        vim.schedule_wrap(function()
          M.apply_theme()
        end)
      )
    end)
  )

  local group = vim.api.nvim_create_augroup("CustomThemeHotReload", { clear = true })
  vim.api.nvim_create_autocmd({ "FocusGained", "VimEnter" }, {
    group = group,
    callback = function()
      local current = M.get_current_theme_name()
      if current ~= last_loaded_theme then
        M.apply_theme()
      end
    end,
  })
end

return M
