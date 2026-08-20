local M = {}

---Get the active working directory context.
---Resolves in order:
---1. Active oil.nvim buffer directory
---2. Active file git root or parent directory
---3. Current working directory (cwd)
---@return string
function M.get_context_dir()
  -- 1. Oil buffer
  local ok, oil = pcall(require, "oil")
  if ok then
    local oil_dir = oil.get_current_dir()
    if oil_dir then
      return oil_dir
    end
  end

  -- 2. Regular file buffer
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname ~= "" and vim.bo.buftype == "" then
    local git_root = vim.fs.root(0, ".git")
    if git_root then
      return git_root
    end
    return vim.fs.dirname(bufname)
  end

  -- 3. Fallback
  return vim.fn.getcwd()
end

return M
