return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({
            lsp_fallback = true,
            async = false,
            timeout_ms = 1000,
          })
        end,
        mode = { "n", "v" },
        desc = "Format file or range",
      },
      {
        "<leader>tf",
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify(
            "Autoformat on save: " .. (vim.g.disable_autoformat and "Disabled" or "Enabled"),
            vim.log.levels.INFO
          )
        end,
        mode = "n",
        desc = "Toggle format on save",
      },
    },
    opts = {
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        rust = { "rustfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        ["_"] = { "trim_whitespace" },
      },
      formatters = {
        stylua = {
          prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        },
        prettier = {
          prepend_args = { "--tab-width", "2" },
        },
        prettierd = {
          prepend_args = { "--tab-width", "2" },
        },
        shfmt = {
          prepend_args = { "-i", "2" },
        },
        clang_format = {
          prepend_args = { "--style={IndentWidth: 2}" },
        },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  -- {
  --   "andymass/vim-matchup",
  --   event = { "BufReadPost", "BufNewFile" },
  --   init = function()
  --     vim.g.matchup_matchparen_deferred = 1
  --     vim.g.matchup_matchparen_hi_surround_always = 0
  --     vim.g.matchup_matchparen_offscreen = { method = "status" }
  --   end,
  -- },
  {
    "echasnovski/mini.indentscope",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local indentscope = require("mini.indentscope")
      return {
        symbol = "│",
        options = { try_as_border = true },
        draw = {
          delay = 150,
          animation = indentscope.gen_animation.none(),
        },
      }
    end,
  },
}
