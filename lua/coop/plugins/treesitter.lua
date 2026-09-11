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
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      enable = true,
      max_lines = 2,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = "outer",
      mode = "topline",
      separator = nil,
      zindex = 20,
    },
    keys = {
      {
        "[c",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        desc = "Jump to upper context",
      },
      {
        "<leader>tc",
        function()
          require("treesitter-context").toggle()
        end,
        desc = "Toggle Treesitter Context",
      },
    },
  },
}
