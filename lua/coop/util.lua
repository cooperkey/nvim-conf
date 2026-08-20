local M = {}

---Find the git repository root for a given path.
---@param path string
---@return string|nil
local function find_git_root(path)
  if not path or path == "" then
    return nil
  end
  return vim.fs.root(path, ".git")
end

---Get the active working directory context.
---Resolves in order:
---1. Active oil.nvim buffer git root or oil dir
---2. Active file git root or parent directory
---3. Cwd git root or cwd
---@return string
function M.get_context_dir()
  -- 1. Oil buffer
  local ok, oil = pcall(require, "oil")
  if ok then
    local oil_dir = oil.get_current_dir()
    if oil_dir then
      local root = find_git_root(oil_dir)
      if root then
        return root
      end
      return oil_dir
    end
  end

  -- 2. Regular file buffer
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname ~= "" and vim.bo.buftype == "" then
    local root = find_git_root(bufname)
    if root then
      return root
    end
    return vim.fs.dirname(bufname)
  end

  -- 3. Fallback to cwd or cwd git root
  local cwd = vim.fn.getcwd()
  local root = find_git_root(cwd)
  return root or cwd
end

return M
