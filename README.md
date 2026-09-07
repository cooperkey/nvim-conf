# nvim-coop

## Requirements

- Neovim >= 0.10
- git
- Node.js + npm
- Python 3 + pip
- Rust + cargo
- PHP + Composer
- A [Nerd Font](https://www.nerdfonts.com/)


## Plugins

### Core

| Plugin | Purpose |
| :--- | :--- |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP configuration |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP/tool installer |
| [blink.cmp](https://github.com/Saghen/blink.cmp) | Completion engine |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | VSCode-style snippet presets |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax parsing & highlighting |

### Navigation

| Plugin | Purpose |
| :--- | :--- |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [harpoon](https://github.com/ThePrimeagen/harpoon) (v2) | File bookmarking & quick nav |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | File explorer as a buffer |
| [flash.nvim](https://github.com/folke/flash.nvim) | Jump & treesitter motion |

### Editing

| Plugin | Purpose |
| :--- | :--- |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Code formatting |
| [nvim-surround](https://github.com/kylechui/nvim-surround) | Surround text objects |
| [mini.pairs](https://github.com/echasnovski/mini.pairs) | Auto-close brackets & quotes |
| [mini.indentscope](https://github.com/echasnovski/mini.indentscope) | Indent scope guide line |
| [vim-matchup](https://github.com/andymass/vim-matchup) | Matching bracket highlight & jump |
| [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | Auto-close HTML/JSX tags |

### UI

| Plugin | Purpose |
| :--- | :--- |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [noice.nvim](https://github.com/folke/noice.nvim) | Cmdline, LSP progress, notifications |
| [nvim-notify](https://github.com/rcarriga/nvim-notify) | Notification popups |

### Git

| Plugin | Purpose |
| :--- | :--- |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | Git commands in Neovim |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git diff signs in gutter |

### Markdown

| Plugin | Purpose |
| :--- | :--- |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Inline Markdown rendering |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Browser preview |

### Colorschemes (lazy-loaded)

bamboo · catppuccin · everforest · flexoki · gruvbox · kanagawa · matteblack · monokai-pro · nord · rose-pine · tokyonight · solarized-osaka · omarchy-amberbyte · osaka-jade

## Language Servers

Configured via native `vim.lsp.config` (Neovim 0.10+ API):

| Server | Language |
| :--- | :--- |
| `lua_ls` | Lua |
| `rust_analyzer` | Rust |
| `clangd` | C / C++ |
| `pyright` | Python |
| `vscode-html-language-server` | HTML |
| `vscode-css-language-server` | CSS / SCSS |
| `vscode-json-language-server` | JSON |
| `typescript-language-server` | JavaScript / TypeScript |
| `jdtls` | Java |

## Formatters (conform.nvim)

| Formatter | Language |
| :--- | :--- |
| `stylua` | Lua |
| `isort` + `black` | Python |
| `prettierd` / `prettier` | JS · TS · JSON · HTML · CSS · Markdown · YAML |
| `rustfmt` | Rust |
| `clang-format` | C / C++ |
| `shfmt` | Bash / Zsh / Shell |
| `trim_whitespace` | All (fallback) |

All formatters enforce **2-space indentation**.

## Keymaps

`<leader>` is `Space`.

### General

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>e` | n | Open file explorer (oil.nvim) |
| `<leader>E` | n | File explorer in float |
| `-` | n | Open parent directory (oil.nvim) |
| `<leader>l` | n | Open lazy.nvim |
| `<leader>z` | n | Colorscheme picker (Telescope) |
| `<leader>n` | n | Notification history |
| `<leader>rs` | n | Restart Neovim |
| `<Esc>` | n/i/s | Clear search highlight |

### Window Management

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<C-h/j/k/l>` | n | Navigate windows |
| `<C-Up/Down>` | n | Resize window height |
| `<C-Left/Right>` | n | Resize window width |

### Search & Navigation

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader><leader>` | n | Find files (Telescope) |
| `<C-p>` | n | Git files (Telescope) |
| `<leader>/` | n | Grep string (Telescope) |
| `<leader>k` | n | Keymap catalogue (Telescope, colored) |
| `<leader>ck` | n | Search keymaps in config files |
| `s` | n/x/o | Flash jump |
| `S` | n/o | Flash treesitter |
| `r` | o | Remote flash |
| `R` | o/x | Treesitter search |

### Harpoon

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>a` | n | Add file to harpoon |
| `<C-e>` | n | Open harpoon menu |
| `<M-a/r/s/t>` | n | Jump to harpoon slots 1-4 |

### Git

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>gg` / `<leader>gs` | n | Open fugitive git panel |
| `<leader>gp` | n | Git push (interactive prompt window) |
| `gp` / `gP` | n (fugitive) | Git push / pull (interactive prompt window) |

### LSP (active on LspAttach)

| Key | Mode | Action |
| :--- | :---: | :--- |
| `K` | n | Hover documentation |
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gi` | n | Go to implementation |
| `go` | n | Go to type definition |
| `gr` | n | Go to references |
| `gs` | n | Signature help |
| `<F2>` | n | Rename symbol |
| `<F3>` | n/x | Format buffer (LSP) |
| `<F4>` | n | Code action |

### Formatting

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>cf` | n/v | Format file or range (conform) |
| `<leader>tf` | n | Toggle format-on-save |

### Completion (blink.cmp)

| Key | Action |
| :--- | :--- |
| `<Down>` / `<C-n>` | Next item |
| `<Up>` / `<C-p>` | Previous item |
| `<Tab>` | Accept suggestion |

### Clipboard

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>y` | n/v | Yank to system clipboard |
| `<leader>Y` | n | Yank line to system clipboard |
| `<leader>d` | n/v | Delete to system clipboard |
| `<leader>p` | x | Paste without overwriting register |

### Markdown

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>mp` | n | Toggle Markdown Preview |
| `<leader>h` | n/v | Highlight word/selection (`<mark>`) |
| `<leader>b` | n/v | Bold |
| `<leader>i` | n/v | Italic |
| `<leader>bi` | n/v | Bold + Italic |
| `<leader>c` | n/v | Inline code |
| `<leader>s` | n/v | Strikethrough |
| `<leader>ml` | n/v | Convert to link |
| `<leader>q` | n | Blockquote |

### Unicode Input

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<C-q>` | n/i | Unicode hex input overlay (4-digit hex, backspace supported) |
| `<leader>U` | n | Unicode character catalogue browser |

### Undotree

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>u` | n | Toggle undo tree |

## Editor Options

- 2-space indentation, expandtab
- Relative line numbers
- Persistent undo (`~/.local/state/nvim/undo`)
- No swap/backup files
- `wrap = true` with visual-line `j/k` navigation
- line-break true
- Live colorscheme watcher via `~/.cache/nvim-live-theme`
- Markdown `<mark>` tag concealment with custom highlight group
