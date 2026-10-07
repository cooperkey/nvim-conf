-- ── Native LSP Setup (no nvim-lspconfig needed on Neovim 0.11+) ─────────────
vim.opt.signcolumn = "yes"

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = function(event)
    local opts = { buffer = event.buf }
    vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
    vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
    vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
    vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
    vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
    vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
    vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
    vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
    vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
  end,
})

local function setup_lsp_servers()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local blink_ok, blink = pcall(require, "blink.cmp")
  if blink_ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  if not vim.lsp.config then
    return
  end

  vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    capabilities = capabilities,
    settings = {
      Lua = {
        telemetry = { enable = false },
        workspace = {
          checkThirdParty = false,
          maxPreload = 500,
          preloadFileSize = 500,
        },
        diagnostics = {
          globals = { "vim" },
        },
      },
    },
  })
  vim.lsp.enable("lua_ls")

  vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
    capabilities = capabilities,
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        procMacro = { enable = true },
        lru = { capacity = 64 },
        files = { watcher = "client" },
        check = {
          command = "check",
          extraArgs = { "--quiet" },
        },
        diagnostics = {
          enable = true,
          experimental = { enable = false },
        },
      },
    },
  })
  vim.lsp.enable("rust_analyzer")

  local servers = {
    harper_ls = {
      cmd = { "harper-ls", "--stdio" },
      filetypes = {
        "markdown",
        "text",
        "rust",
        "python",
        "javascript",
        "typescript",
        "typescriptreact",
        "html",
        "css",
        "lua",
        "c",
        "cpp",
        "gitcommit",
      },
      settings = {
        ["harper-ls"] = {
          linters = {
            SpellCheck = true,
            SentenceCapitalization = false,
            LongSentences = false,
            RepeatedWords = true,
            Spaces = true,
          },
        },
      },
    },
    clangd = {
      cmd = {
        "clangd",
        "-j=2",
        "--background-index",
        "--completion-style=bundled",
        "--header-insertion=iwyu",
      },
      filetypes = { "c", "cpp", "objc", "objcpp" },
    },
    pyright = {
      cmd = { "pyright-langserver", "--stdio" },
      filetypes = { "python" },
      settings = {
        python = {
          analysis = {
            autoSearchPaths = false,
            useLibraryCodeForTypes = false,
            diagnosticMode = "openFilesOnly",
            indexing = false,
            typeCheckingMode = "off",
          },
        },
      },
    },
    html = { cmd = { "vscode-html-language-server", "--stdio" }, filetypes = { "html" } },
    cssls = { cmd = { "vscode-css-language-server", "--stdio" }, filetypes = { "css", "scss", "less" } },
    jsonls = { cmd = { "vscode-json-language-server", "--stdio" }, filetypes = { "json", "jsonc" } },
    ts_ls = {
      cmd = { "typescript-language-server", "--stdio" },
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    },
    jdtls = {},
  }

  for server, config in pairs(servers) do
    config.capabilities = capabilities
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
  end
end

-- Defer LSP setup to ensure blink.cmp is loaded by lazy.nvim first
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = setup_lsp_servers,
})

local is_android = (vim.fn.has("android") == 1)
    or (vim.env.PREFIX ~= nil and vim.env.PREFIX:find("com%.termux") ~= nil)

return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
    build = ":MasonUpdate",
    opts = {
      PATH = "append",
      max_concurrent_installers = is_android and 1 or 4,
      ui = {
        border = "rounded",
        icons = {
          package_installed = "+",
          package_pending = "~",
          package_uninstalled = "-",
        },
      },
    },
  },
  -- {
  --   "L3MON4D3/LuaSnip",
  --   build = "make install_jsregexp",
  --   dependencies = { "rafamadriz/friendly-snippets" },
  --   config = function()
  --     require("luasnip.loaders.from_vscode").lazy_load()
  --   end,
  -- },
  {
    "Saghen/blink.cmp",
    version = "*",
    build = "cargo build --release",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      snippets = {
        preset = "default",
      },
      keymap = {
        preset = "none",
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<Tab>"] = { "accept", "fallback" },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        trigger = {
          show_on_keyword = true,
          show_on_trigger_character = true,
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            fallbacks = {},
          },
          path = {
            fallbacks = {},
          },
          buffer = {
            min_keyword_length = 3,
          },
        },
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        inline = {
          adapter = "copilot",
        },
      },
      display = {
        diff = {
          enabled = true,
          provider = "default",
        },
      },
    },
    keys = {
      { "<leader>ci", ":CodeCompanion ",               mode = { "n", "v" }, desc = "Inline Prompt" },
      { "<leader>ca", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "Inline Actions" },
    },
  },
}
