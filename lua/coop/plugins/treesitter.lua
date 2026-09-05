return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",

    config = function()
      local ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      }

      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup({
          ensure_installed = ensure_installed,
          sync_install = false,
          auto_install = true,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = {
            enable = true,
          },
        })
      else
        local ts_ok, ts = pcall(require, "nvim-treesitter")
        if ts_ok then
          ts.setup()
          pcall(ts.install, ensure_installed)
        end
        vim.api.nvim_create_autocmd("FileType", {
          desc = "Enable treesitter highlighting",
          callback = function(args)
            pcall(vim.treesitter.start, args.buf)
          end,
        })
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function() end,
  },
}
