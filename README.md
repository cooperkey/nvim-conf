# nvim-coop

## Requirements

- Neovim >= 0.10
- git
- Node.js + npm (Prettier, pyright, typescript-language-server, markdown-preview)
- Python 3 + pip (isort, black)
- Rust + cargo (blink.cmp build, rust-analyzer, rustfmt)
- C/C++ compiler + tools (clangd, clang-format)
- A [Nerd Font](https://www.nerdfonts.com/)

## Plugins

### Core

| Plugin | Purpose |
| :--- | :--- |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| Native `vim.lsp` (0.11+) | Built-in LSP client configuration & management |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP/tool installer (lazy-loaded on command) |
| [blink.cmp](https://github.com/Saghen/blink.cmp) | High-performance completion engine |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax parsing & highlighting |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Treesitter syntax-aware text objects |
| [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | Sticky code context at top of window |
| [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) | LLM chat, inline generation & actions |

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
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Code formatting engine |
| [nvim-surround](https://github.com/kylechui/nvim-surround) | Surround text objects |
| [mini.pairs](https://github.com/echasnovski/mini.pairs) | Auto-close brackets & quotes |
| [mini.indentscope](https://github.com/echasnovski/mini.indentscope) | Indent scope guide line |
| [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | Auto-close HTML/JSX tags |
| [undotree](https://github.com/mbbill/undotree) | Visual undo history visualizer |

### UI

| Plugin | Purpose |
| :--- | :--- |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline with tmux window integration |
| [noice.nvim](https://github.com/folke/noice.nvim) | Minimal popup cmdline & message routing |
| Custom `vim.notify` | Stacking notifications one line above lualine (up to 3 concurrent, full height for multiline) |
| Custom Dashboard | Fast, zero-dependency startup dashboard |
| [nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors) | Color preview highlighter |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | File icons |

### Git

| Plugin | Purpose |
| :--- | :--- |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | Comprehensive Git wrapper & status index |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git diff signs in gutter |

### Markdown

| Plugin | Purpose |
| :--- | :--- |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Inline Markdown rendering & LaTeX |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Browser preview |

### Colorschemes (lazy-loaded)

`acme` · `afterglow` · `apprentice` · `b2t` · `bamboo` · `base16` · `black-metal` (with `darkthrone`) · `catppuccin` · `dracula` · `everforest` · `flexoki` · `gruvbox` · `gruvbox-material` · `kanagawa` · `mars` · `matteblack` · `miasma` · `monokai-pro` · `nes` · `nightfox` · `osaka-jade` · `papercolor` · `rose-pine` · `snow` · `solarize` (`solarized-osaka`) · `tokyonight` · `zenburn`

## Language Servers

Configured via native `vim.lsp.config` (Neovim 0.10+ API):

| Server | Language |
| :--- | :--- |
| `lua_ls` | Lua |
| `rust_analyzer` | Rust |
| `clangd` | C / C++ |
| `pyright` | Python |
| `html` (`vscode-html-language-server`) | HTML |
| `cssls` (`vscode-css-language-server`) | CSS / SCSS |
| `jsonls` (`vscode-json-language-server`) | JSON |
| `ts_ls` (`typescript-language-server`) | JavaScript / TypeScript |
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
| `trim_whitespace` | Fallback for all filetypes |

Default formatters enforce **2-space indentation** (Python enforces PEP 8 **4-space indentation**).

## Keymaps

`<leader>` is `Space`.

### General & Editor

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>e` | n | Open file explorer (oil.nvim) |
| `<leader>E` | n | File explorer in floating window (oil.nvim) |
| `-` | n | Open parent directory (oil.nvim) |
| `<leader>l` | n | Open lazy.nvim panel |
| `<leader>z` | n | Colorscheme picker (Telescope) |
| `<leader>n` | n | Notification history (Telescope) |
| `<leader>so` | n | Restart Neovim (`:restart!`) |
| `<leader>rs` | n/v | Global find-and-replace word / visual selection |
| `<leader>;` | n | Append semicolon at end of line |
| `<A-;>` | i | Append semicolon at end of line |
| `<Esc>` | n/i/s | Clear search highlight (`noh`) |
| `<leader>up` | n | Toggle auto-pairs (`mini.pairs`) |
| `<leader>u` | n | Toggle undo history tree (`undotree`) |

### Windows, Splits & Buffers

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<C-h/j/k/l>` | n | Focus window left / down / up / right |
| `<C-Up/Down>` | n | Resize window height (+/- 2) |
| `<C-Left/Right>` | n | Resize window width (-/+ 2) |
| `<M-v>` | n | Split window vertically (`:vsplit`) |
| `<M-h>` | n | Split window horizontally (`:split`) |
| `<M-q>` | n/t | Close current split window |
| `<leader>,` | n | Alternate buffer / previous window (`<C-^>`) |
| `<leader>bn` | n | Next buffer (`:bnext`) |
| `<leader>bp` | n | Previous buffer (`:bprevious`) |
| `<leader>bd` | n | Close current buffer (safe) |
| `<leader>bo` | n | Close all other inactive buffers |

### Quickfix

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<M-n>` | n | Next quickfix item (`:cnext`) |
| `<M-p>` | n | Previous quickfix item (`:cprev`) |
| `<M-o>p` | n | Open quickfix list (`:copen`) |
| `<M-o>s` | n | Close quickfix list (`:cclose`) |

### Movement & Clipboard

| Key | Mode | Action |
| :--- | :---: | :--- |
| `J` / `K` | v | Move selected lines down / up |
| `<` / `>` | v | Indent left / right and keep selection |
| `J` | n | Join lines without moving cursor |
| `<C-d>` / `<C-u>` | n | Half-page scroll down / up (centered) |
| `<leader>y` | n/v | Yank to system clipboard (`"+y`) |
| `<leader>Y` | n | Yank line to system clipboard (`"+Y`) |
| `<leader>d` | n/v | Delete to system clipboard (`"+d`) |
| `<leader>D` | n | Delete line to system clipboard (`"+dd`) |
| `<leader>p` | x | Paste without overwriting default register |

### Search & Navigation (Telescope & Flash)

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader><leader>` | n | Find files in context directory (Telescope) |
| `<C-p>` | n | Git files in context directory (Telescope) |
| `<C-f>` | n | Switch project session (`tmux-sessionizer`) |
| `<leader>/` | n | Live grep in context directory (Telescope) |
| `<leader>gw` | n | Grep word under cursor in context directory (Telescope) |
| `<leader>k` | n | Keymap catalogue browser (Telescope, color-coded) |
| `<leader>ck` | n | Grep keymaps inside nvim config files |
| `s` | n/x/o | Flash jump |
| `S` | n/o | Flash treesitter node |
| `r` | o | Flash remote jump |
| `R` | o/x | Flash treesitter search |

### Treesitter & Context

| Key | Mode | Action |
| :--- | :---: | :--- |
| `af` / `if` | x/o | Around / inside function |
| `ai` / `ii` | x/o | Around / inside conditional (`if` / `else`) |
| `ac` / `ic` | x/o | Around / inside comment |
| `[c` | n | Jump up to context header |
| `<leader>tc` | n | Toggle Treesitter context |

### Harpoon (v2)

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>a` | n | Add current file to harpoon |
| `<C-e>` | n | Open harpoon quick menu |
| `<M-a>` | n | Select harpoon slot 1 |
| `<M-r>` | n | Select harpoon slot 2 |
| `<M-s>` | n | Select harpoon slot 3 |
| `<M-t>` | n | Select harpoon slot 4 |

### Git

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>gg` / `<leader>gs` | n | Open Fugitive git status panel |
| `:SSHAdd` | cmd | Load SSH key into agent (`ssh-add`) |

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
| `<F4>` | n | Code actions |

### AI (CodeCompanion)

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>ci` | n/v | CodeCompanion inline prompt |
| `<leader>ca` | n/v | CodeCompanion inline actions menu |

### Formatting (conform.nvim)

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>cf` | n/v | Format file or visual selection (conform) |
| `<leader>tf` | n | Toggle auto-format on save |

### Completion (blink.cmp)

| Key | Action |
| :--- | :--- |
| `<Down>` / `<C-n>` | Next completion candidate |
| `<Up>` / `<C-p>` | Previous completion candidate |
| `<Tab>` | Accept suggestion |

### Markdown Workflow

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<leader>mp` | n | Toggle Markdown Preview in browser |
| `<leader>mP` | n | Stop Markdown Preview server |
| `<leader>x` | n/v | Toggle / create checklist item (`- [ ]` / `- [x]`) |
| `<leader>h` | n/v | Highlight word / selection (`<mark>`) |
| `<leader>mc` | n | Choose `<mark>` highlight accent color |
| `<leader>b` | n/v | Bold (`**text**`) |
| `<leader>i` | n/v | Italic (`_text_`) |
| `<leader>bi` | n/v | Bold + Italic (`**_text_**`) |
| `<leader>c` | n/v | Inline code (`` `text` ``) |
| `<leader>s` | n/v | Strikethrough (`~~text~~`) |
| `<leader>ml` | n/v | Convert word / selection to link (`[text]()`) |
| `<leader>cb` | v | Wrap selection in fenced code block (```` ``` ````) |
| `<leader>mr` | v | Strip markdown formatting from selection |
| `<leader>1` - `<leader>6` | n | Set heading level 1 through 6 |
| `gl` / `<leader>mg` | n | Follow link under cursor (URL, file, or `#anchor`) |
| `]]` / `[[` | n | Jump to next / previous heading |
| `<leader>mt` | n | Generate and insert markdown table |
| `<leader>mw` | n | Display word, line, and character count |

### Unicode Input

| Key | Mode | Action |
| :--- | :---: | :--- |
| `<C-q>` | n/i | Unicode hex input overlay (4-digit hex, live preview) |
| `<leader>U` | n | Unicode character catalogue browser |

### Resource Management & Process Control

| Key / Command | Mode | Action |
| :--- | :---: | :--- |
| `<leader>ts` / `<leader>ls` | n | Toggle LSP and background job suspension |
| `:LspStatus` | cmd | Display resource dashboard (PID, RSS memory, timers) |
| `:LspSuspend` | cmd | Explicitly stop active LSPs & freeze terminal jobs (if enabled) |
| `:LspResume` | cmd | Reattach LSP across all open split buffers & unfreeze jobs |
| `:LspToggle` | cmd | Toggle suspend/resume state |

## Editor Options

- 2-space indentation default, expandtab (Python enforces 4 spaces via PEP 8)
- Relative line numbers (automatically toggles to absolute in Insert mode)
- Persistent undo (`~/.local/state/nvim/undo`)
- No swap or backup files
- Treesitter-based folding with fast manual folding during insert mode
- `wrap = true` with `linebreak`, `breakindent`, and visual-line navigation (`j/k`)
- Automatic theme hot-reloading via `~/.cache/nvim-live-theme` and `~/.config/custom/current/`
- Markdown `<mark>` tag concealment with customizable highlight group
- Tmux statusbar toggle (hides tmux status while nvim is active, restores on leave)
- Stacking notifications one line above lualine (up to 3 concurrent; multi-line messages display at full height)

## Cross-Platform Architecture & Agentic Coding Directives (Termux vs Desktop Linux)

This Neovim configuration is shared via Git across both **Android (Termux)** and **Desktop Linux (Hyprland / Wayland / Foot)**.

Any automated agent or developer modifying this configuration **must** adhere to the following architectural invariants:

### 1. Platform Detection Standard
Always detect platform differences using strict boolean expressions:
```lua
local is_android = (vim.fn.has("android") == 1)
  or (vim.env.PREFIX ~= nil and vim.env.PREFIX:find("com%.termux") ~= nil)
```
*Never* rely on Lua truthiness hacks like `A and B or C` when `B` might be `nil` or `false`.

### 2. Environment Divergence & Tuning Invariants

| Parameter / Behavior | Termux (Android Mobile) | Desktop Linux (Workstation) | Rationale |
| :--- | :--- | :--- | :--- |
| `suspend_compilers` | `true` | `false` | On desktop, freezing terminal buffers stops active background builds (`cargo build`), test runners, dev servers (`vite`), and drops SSH connections. On Termux, stopping CPU jobs prevents battery drain and OS-level task killing. |
| `focus_lost_timeout` | `180000` (3 minutes) | `1800000` (30 minutes) | Desktop tiling window managers (Hyprland) switch focus constantly. Killing LSPs after 3 minutes causes severe cold-start latency (`rust-analyzer`, `clangd` re-indexing). |
| `idle_timeout` | `480000` (8 minutes) | `3600000` (60 minutes) | Workstations have abundant RAM; mobile devices suffer from Android LowMemoryKiller (LMKD). |
| `orphan_debounce` | `15000` (15 seconds) | `60000` (60 seconds) | Closing a buffer to switch files should not immediately kill language servers on high-memory desktop environments. |

### 3. Process Signaling & Procfs Rules
- **Process Group Fallback**: When issuing signals via `vim.uv.kill(pid, sig)`, always signal the process group (`-pid`) first, but *must* provide an immediate fallback to `pid` if group signaling fails.
- **VimLeavePre Cleanup**: No process must ever be left in `SIGSTOP` (`T` state) on Neovim exit. All suspended jobs must be cleanly signaled with `SIGCONT`.
- **Procfs Direct Access**: On Linux, read `/proc/<pid>/task/<pid>/children` directly for instantaneous child PID lookups. Fall back to `pgrep -P` only on Android/Termux where task children nodes may be restricted by the vendor kernel. Never run synchronous subshells (`io.popen`) in hot paths or event loops.

### 4. LSP & Buffer Handling
- **Multi-Split Awareness**: When resuming LSPs, iterate over all valid windows (`vim.api.nvim_list_wins()`) and attach across visible buffers. Never assume `vim.api.nvim_get_current_buf()` is the only displayed buffer.
- **Orphan Client Filtering**: A buffer attached to an LSP is valid if it is loaded AND either `buflisted` OR currently displayed in any window (`vim.fn.bufwinid(bufnr) ~= -1`). Do not terminate LSPs serving unlisted diff, fugitive, or preview buffers.
- **API Modernization**: Use Neovim 0.12+ public APIs (e.g. `vim.lsp.get_configs({ enabled = true, filetype = ft })`) while retaining backward-compatible fallbacks for Neovim 0.10/0.11. Never bind directly to private tables (e.g. `vim.lsp.config._configs`) without public fallbacks.

### 5. Pathing & Binaries
- Do not assume absolute paths (`/usr/bin` vs `/data/data/com.termux/files/usr/bin`).
- Always check binary presence via `vim.fn.executable(...) == 1` before invoking external CLI tools or daemons.

