return {
  { "williamboman/mason.nvim", opts = {} },
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
            min_keyword_length = 1,
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "Saghen/blink.cmp",
    },
    config = function()
      vim.opt.signcolumn = "yes"

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local blink_status, blink = pcall(require, "blink.cmp")
      if blink_status then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

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

      if vim.lsp.config then
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
    end,
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
            adapter = "copilot", -- change to "copilot" if using ~/.config/github-copilot/hosts.json
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
        { "<leader>ci", ":CodeCompanion ", mode = { "n", "v" }, desc = "Inline Prompt" },
        { "<leader>ca", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "Inline Actions" },
      },
    },
}
