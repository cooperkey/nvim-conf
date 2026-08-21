vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open oil (Explorer)" })
vim.keymap.set("n", "<leader>so", [[:restart<CR>]], { desc = "Restart nvim" })

-- Auto-indent on empty/blank lines when entering insert mode
vim.keymap.set("n", "i", function()
  if #vim.fn.getline(".") == 0 or vim.fn.getline("."):match("^%s*$") then
    return [["_cc]]
  else
    return "i"
  end
end, { expr = true, desc = "Smart insert with auto-indent" })

vim.keymap.set("n", "a", function()
  if #vim.fn.getline(".") == 0 or vim.fn.getline("."):match("^%s*$") then
    return [["_cc]]
  else
    return "a"
  end
end, { expr = true, desc = "Smart append with auto-indent" })


-- Window Splits
vim.keymap.set("n", "<M-v>", "<cmd>vsplit<cr>", { desc = "Split vertically" })
vim.keymap.set("n", "<M-h>", "<cmd>split<cr>", { desc = "Split horizontally" })
vim.keymap.set({ "n", "t" }, "<M-q>", "<cmd>close<cr>", { desc = "Close current split window" })
vim.keymap.set("n", "<leader>,", "<c-^>", { desc = "Previous window" })

-- textobjects from treesitter
vim.keymap.set({ "x", "o" }, "ai", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@conditional.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ii", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@conditional.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "af", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "if", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ac", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@comment.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ic", function()
  require "nvim-treesitter-textobjects.select".select_textobject("@comment.inner", "textobjects")
end)


-- Clear search highlight on single Escape in Normal mode
vim.keymap.set({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })


-- Navigate by visual display lines when text wraps (j/k and arrow keys)
vim.keymap.set({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "v" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })

-- move to window using Ctrl+hjkl or Alt+Arrows
vim.keymap.set("n", "<c-h>", "<c-w>h", { desc = "go to left window", remap = true })
vim.keymap.set("n", "<c-j>", "<c-w>j", { desc = "go to lower window", remap = true })
vim.keymap.set("n", "<c-k>", "<c-w>k", { desc = "go to upper window", remap = true })
vim.keymap.set("n", "<c-l>", "<c-w>l", { desc = "go to right window", remap = true })

vim.keymap.set("n", "<m-n>", "<cmd>cnext<cr>", { desc = "Next quick fix", remap = true })
vim.keymap.set("n", "<m-p>", "<cmd>cprev<cr>", { desc = "Previous quick fix", remap = true })
vim.keymap.set("n", "<m-o>p", "<cmd>copen<cr>", { desc = "Open quick fix", remap = true })
vim.keymap.set("n", "<m-o>s", "<cmd>cclose<cr>", { desc = "Close quick fix", remap = true })


-- resize window
vim.keymap.set("n", "<c-up>", "<cmd>resize +2<cr>", { desc = "increase window height" })
vim.keymap.set("n", "<c-down>", "<cmd>resize -2<cr>", { desc = "decrease window height" })
vim.keymap.set("n", "<c-left>", "<cmd>vertical resize -2<cr>", { desc = "decrease window width" })
vim.keymap.set("n", "<c-right>", "<cmd>vertical resize +2<cr>", { desc = "increase window width" })

-- commenting
vim.keymap.set("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment below" })
vim.keymap.set("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment below" })



-- move highlighted part
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move highlighted part down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move highlighted part down" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "move below to same line of cursor" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down halfw1y" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll down halfway" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste and not copy the highlighted" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Copy line to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["+d]], { desc = " delete to clipboard" })
vim.keymap.set("n", "<leader>D", [["+dd]], { desc = " delete line to clipboard" })


vim.keymap.set("n", "<leader>rs", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor" })
vim.keymap.set("v", "<leader>rs", [["hy:<C-u>%s/<C-r>h/<C-r>h/gI<Left><Left><Left>]], { desc = "Replace selected text" })

vim.keymap.set("n", "<leader>l", [[:Lazy<CR>]], { desc = "open lazy" })
vim.keymap.set("n", "<leader>n", [[:Telescope noice<CR>]], { desc = "Open notifications (noice)" })

vim.keymap.set("n", "<leader>z", [[:Telescope colorscheme<CR>]], { desc = "open colorscheme" })


vim.keymap.set('t', '<esc>', [[<c-\><c-n>]], { desc = "Normal layer in Terminal" })

-- Markdown
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle Markdown Preview" })

-- oil.nvim
vim.keymap.set("n", "<leader>e", function() require("oil").open() end, { desc = "File Explorer (oil)" })
vim.keymap.set("n", "<leader>E", function() require("oil").open_float() end, { desc = "File Explorer float (oil)" })
vim.keymap.set("n", "-", function() require("oil").open() end, { desc = "Open parent dir (oil)" })

-- ── 5. Markdown Workflow Keymaps ──────────────────────────────────────────
-- Global Markdown Shortcuts
vim.keymap.set("v", "<leader>h", "<esc>`>a</mark><esc>`<i<mark><esc>",
  { desc = "Highlight selection (Markdown)", nowait = true })
vim.keymap.set("n", "<leader>h", "viw<esc>`>a</mark><esc>`<i<mark><esc>",
  { desc = "Highlight word (Markdown)", nowait = true })

vim.keymap.set("v", "<leader>i", "<esc>`>a*<esc>`<i*<esc>", { desc = "Italic selection (Markdown)" })
vim.keymap.set("n", "<leader>i", "viw<esc>`>a*<esc>`<i*<esc>", { desc = "Italic word (Markdown)" })

vim.keymap.set("v", "<leader>b", "<esc>`>a**<esc>`<i**<esc>", { desc = "Bold selection (Markdown)" })
vim.keymap.set("n", "<leader>b", "viw<esc>`>a**<esc>`<i**<esc>", { desc = "Bold word (Markdown)" })

vim.keymap.set("v", "<leader>bi", "<esc>`>a***<esc>`<i***<esc>", { desc = "Bold/Italic selection (Markdown)" })
vim.keymap.set("n", "<leader>bi", "viw<esc>`>a***<esc>`<i***<esc>", { desc = "Bold/Italic word (Markdown)" })

vim.keymap.set("v", "<leader>c", "<esc>`>a`<esc>`<i`<esc>", { desc = "Inline code selection (Markdown)" })
vim.keymap.set("n", "<leader>c", "viw<esc>`>a`<esc>`<i`<esc>", { desc = "Inline code word (Markdown)" })

vim.keymap.set("v", "<leader>s", "<esc>`>a~~<esc>`<i~~<esc>", { desc = "Strikethrough selection (Markdown)" })
vim.keymap.set("n", "<leader>s", "viw<esc>`>a~~<esc>`<i~~<esc>", { desc = "Strikethrough word (Markdown)" })

vim.keymap.set("v", "<leader>ml", "<esc>`>a]()<esc>`<i[<esc>f(a", { desc = "Convert to link (Markdown)" })
vim.keymap.set("n", "<leader>ml", "viw<esc>`>a]()<esc>`<i[<esc>f(a", { desc = "Convert word to link (Markdown)" })

vim.keymap.set({ "n", "v" }, "<leader>x", function()
  local mode = vim.api.nvim_get_mode().mode
  local start_line, end_line

  if mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" or mode == "\22" then
    vim.cmd("normal! \27")
    start_line = math.min(vim.fn.line("'<"), vim.fn.line("'>"))
    end_line = math.max(vim.fn.line("'<"), vim.fn.line("'>"))
  else
    start_line = vim.api.nvim_win_get_cursor(0)[1]
    end_line = start_line
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local updated_lines = {}
  local count_checked = 0
  local count_unchecked = 0
  local count_created = 0

  for _, line in ipairs(lines) do
    if line:match("%-%s*%[ %]") then
      line = line:gsub("%-%s*%[ %]", "- [x]", 1)
      count_checked = count_checked + 1
    elseif line:match("%-%s*%[x%]") or line:match("%-%s*%[X%]") then
      line = line:gsub("%-%s*%[x%]", "- [ ]", 1)
      line = line:gsub("%-%s*%[X%]", "- [ ]", 1)
      count_unchecked = count_unchecked + 1
    else
      line = "- [ ] " .. line:gsub("^%s*", "")
      count_created = count_created + 1
    end
    table.insert(updated_lines, line)
  end

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, updated_lines)

  if #lines == 1 then
    if count_checked > 0 then
      vim.notify("✓ Checklist item checked", vim.log.levels.INFO)
    elseif count_unchecked > 0 then
      vim.notify("○ Checklist item unchecked", vim.log.levels.INFO)
    else
      vim.notify("+ Checklist item created", vim.log.levels.INFO)
    end
  else
    vim.notify("Checklist updated (" .. #lines .. " lines)", vim.log.levels.INFO)
  end
end, { desc = "Toggle Markdown checklist" })

vim.keymap.set("v", "<leader>cb", function()
  vim.cmd("normal! \27")
  local start_line = math.min(vim.fn.line("'<"), vim.fn.line("'>"))
  local end_line   = math.max(vim.fn.line("'<"), vim.fn.line("'>"))
  vim.fn.append(end_line, "```")
  vim.fn.append(start_line - 1, "```")
  vim.api.nvim_win_set_cursor(0, { start_line, 3 })
  vim.cmd("startinsert!")
end, { desc = "Fenced code block (Markdown)" })

vim.keymap.set("n", "<leader>mc", function()
  local choices = {
    { name = "Yellow/Orange (Warning)",  group = "DiagnosticWarn" },
    { name = "Red (Error)",              group = "DiagnosticError" },
    { name = "Blue (Info)",              group = "DiagnosticInfo" },
    { name = "Green (String)",           group = "String" },
    { name = "Teal (Hint)",              group = "DiagnosticHint" },
    { name = "Magenta/Purple (Special)", group = "Special" },
  }
  vim.ui.select(choices, {
    prompt = "Select Markdown Highlight Color:",
    format_item = function(item) return item.name end,
  }, function(choice)
    if not choice then return end
    vim.g.markdown_highlight_group = choice.group
    if _G.set_markdown_highlight then
      _G.set_markdown_highlight()
    end
    vim.notify("✓ Markdown highlight color set to: " .. choice.name, vim.log.levels.INFO)
  end)
end, { desc = "Choose Highlight Color (Markdown)" })

-- Buffer-local Markdown Keymaps & Helpers
local function apply_md_keymaps(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.bo[buf].filetype ~= "markdown" then return end

  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
  end

  local function set_heading(level)
    local line = vim.api.nvim_get_current_line()
    line = line:gsub("^#+%s*", "")
    vim.api.nvim_set_current_line(string.rep("#", level) .. " " .. line)
  end
  map("n", "<leader>1", function() set_heading(1) end, "Heading 1 (Markdown)")
  map("n", "<leader>2", function() set_heading(2) end, "Heading 2 (Markdown)")
  map("n", "<leader>3", function() set_heading(3) end, "Heading 3 (Markdown)")
  map("n", "<leader>4", function() set_heading(4) end, "Heading 4 (Markdown)")
  map("n", "<leader>5", function() set_heading(5) end, "Heading 5 (Markdown)")
  map("n", "<leader>6", function() set_heading(6) end, "Heading 6 (Markdown)")

  local function toggle_prefix(prefix)
    local line = vim.api.nvim_get_current_line()
    if line:sub(1, #prefix) == prefix then
      vim.api.nvim_set_current_line(line:sub(#prefix + 1))
    else
      line = line:gsub("^#+%s*", ""):gsub("^>%s*", ""):gsub("^%-%s*", ""):gsub("^%d+%.%s*", "")
      vim.api.nvim_set_current_line(prefix .. line)
    end
  end
  map("n", "<leader>-", function() toggle_prefix("- ") end, "Bullet list item (Markdown)")
  map("n", "<leader>o", function() toggle_prefix("1. ") end, "Ordered list item (Markdown)")
  map("n", "<leader>q", function() toggle_prefix("> ") end, "Blockquote (Markdown)")

  local function follow_markdown_link()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1

    local links = {}
    local pattern = "%[([^%]]-)%]%(([^%)]+)%)"
    local init = 1
    while true do
      local s, e, label, url = line:find(pattern, init)
      if not s then break end
      table.insert(links, { start_col = s, end_col = e, label = label, url = url })
      init = e + 1
    end

    local chosen = nil
    for _, link in ipairs(links) do
      if col >= link.start_col and col <= link.end_col then
        chosen = link
        break
      end
    end
    if not chosen and #links > 0 then
      chosen = links[1]
    end

    if not chosen then
      vim.notify("No markdown link found on current line", vim.log.levels.WARN)
      return
    end

    local url = chosen.url:gsub("^%s*", ""):gsub("%s*$", "")

    if url:match("^https?://") then
      if vim.ui.open then
        vim.ui.open(url)
      else
        vim.fn.jobstart({ "termux-open-url", url })
      end
      vim.notify("Opened URL: " .. url, vim.log.levels.INFO)
      return
    end

    local file_part, anchor_part = url:match("^([^#]*)#(.*)$")
    if not file_part and not anchor_part then
      file_part = url
    end

    if file_part and file_part ~= "" then
      local buf_dir = vim.fn.expand("%:p:h")
      local rel_file = buf_dir .. "/" .. file_part
      if vim.fn.filereadable(file_part) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(file_part))
      elseif vim.fn.filereadable(rel_file) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(rel_file))
      else
        vim.notify("File not found: " .. file_part, vim.log.levels.ERROR)
        return
      end
    end

    if anchor_part and anchor_part ~= "" then
      local anchor_raw = anchor_part:lower()

      local function slugify(h_text)
        local t = h_text:gsub("^#+%s*", ""):lower()
        t = t:gsub("%s*—%s*", "--")
        t = t:gsub("%s*–%s*", "-")
        t = t:gsub("[^%w%s%-_]", "")
        t = t:gsub("%s+", "-")
        return t
      end

      local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local target_line = nil

      for idx, l in ipairs(buf_lines) do
        if l:match("^#+%s") then
          local slug = slugify(l)
          if slug == anchor_raw then
            target_line = idx
            break
          end
        end
      end

      if not target_line then
        local words = {}
        for word in anchor_raw:gmatch("%w+") do
          if #word > 1 then
            table.insert(words, word)
          end
        end

        if #words > 0 then
          local max_matches = 0
          for idx, l in ipairs(buf_lines) do
            if l:match("^#+%s") then
              local l_lower = l:lower()
              local matches = 0
              for _, w in ipairs(words) do
                if l_lower:find(w, 1, true) then
                  matches = matches + 1
                end
              end
              if matches > max_matches then
                max_matches = matches
                target_line = idx
              end
            end
          end
        end
      end

      if target_line then
        vim.api.nvim_win_set_cursor(0, { target_line, 0 })
        vim.cmd("normal! zt")
        vim.notify("Jumped to heading (line " .. target_line .. ")", vim.log.levels.INFO)
      else
        vim.notify("Anchor heading not found: #" .. anchor_part, vim.log.levels.WARN)
      end
    end
  end

  map("n", "gl", follow_markdown_link, "Follow link under cursor (Markdown)")
  map("n", "gx", follow_markdown_link, "Follow link under cursor (Markdown)")
  map("n", "<leader>mg", follow_markdown_link, "Follow link under cursor (Markdown)")

  map("n", "]]", function() vim.fn.search("^#\\+\\s", "W") end, "Next heading (Markdown)")
  map("n", "[[", function() vim.fn.search("^#\\+\\s", "bW") end, "Prev heading (Markdown)")

  map("n", "<leader>mt", function()
    vim.ui.input({ prompt = "Rows: " }, function(rows_str)
      local rows = tonumber(rows_str)
      if not rows or rows < 1 then return end
      vim.ui.input({ prompt = "Cols: " }, function(cols_str)
        local cols = tonumber(cols_str)
        if not cols or cols < 1 then return end
        local headers, seps = {}, {}
        for c = 1, cols do
          headers[c] = " Column" .. c .. " "
          seps[c]    = " --------------- "
        end
        local tbl = {
          "|" .. table.concat(headers, "|") .. "|",
          "|" .. table.concat(seps, "|") .. "|",
        }
        for r = 1, rows do
          local cells = {}
          for c = 1, cols do
            cells[c] = " Item" .. c .. "." .. r .. " "
          end
          tbl[#tbl + 1] = "|" .. table.concat(cells, "|") .. "|"
        end
        vim.fn.append(vim.fn.line("."), tbl)
        vim.notify(string.format("󰓫 Table inserted (%d × %d)", rows, cols), vim.log.levels.INFO)
      end)
    end)
  end, "Insert table (Markdown)")

  map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", "Toggle Markdown Preview")
  map("n", "<leader>mP", "<cmd>MarkdownPreviewStop<cr>", "Stop Markdown Preview")

  map("n", "<leader>mw", function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local text  = table.concat(lines, " ")
    local words = 0
    for _ in text:gmatch("%S+") do words = words + 1 end
    vim.notify(
      string.format("󰈙  Words: %d  ·  Lines: %d  ·  Chars: %d", words, #lines, #text:gsub("%s", "")),
      vim.log.levels.INFO
    )
  end, "Word count (Markdown)")

  map("v", "<leader>mr", function()
    local s = vim.fn.line("'<")
    local e = vim.fn.line("'>")
    for i = s, e do
      local ln = vim.fn.getline(i)
      ln = ln:gsub("%*%*%*(.-)%*%*%*", "%1")
      ln = ln:gsub("%*%*(.-)%*%*", "%1")
      ln = ln:gsub("%*(.-)%*", "%1")
      ln = ln:gsub("~~(.-)~~", "%1")
      ln = ln:gsub("`(.-)`", "%1")
      ln = ln:gsub("==(.-)==", "%1")
      vim.fn.setline(i, ln)
    end
    vim.notify("✓ Formatting removed from selection", vim.log.levels.INFO)
  end, "Remove formatting (Markdown)")
end

vim.api.nvim_create_autocmd("FileType", {
  pattern  = "markdown",
  group    = vim.api.nvim_create_augroup("markdown_workflow_keymaps", { clear = true }),
  callback = function(ev) apply_md_keymaps(ev.buf) end,
})

for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.bo[buf].filetype == "markdown" then
    apply_md_keymaps(buf)
  end
end

-- ── 6. General Utilities ──────────────────────────────────────────────────
-- Floating Shortcuts Cheatsheet
vim.keymap.set("n", "<leader>?", function()
  local lines = {
    "                                          ",
    "   FORMATTING              n = word   v = selection  ",
    "                                          ",
    "   <leader> b      Bold                   ",
    "   <leader> i      Italic                 ",
    "   <leader> bi     Bold + Italic          ",
    "   <leader> h      Highlight  (==)        ",
    "   <leader> c      Inline code  (`)       ",
    "   <leader> s      Strikethrough  (~~)    ",
    "   <leader> mr     Remove formatting  [v] ",
    "                                          ",
    "   STRUCTURE                              ",
    "                                          ",
    "   <leader> 1/2/3  Heading H1 / H2 / H3  ",
    "   <leader> -      Bullet list  (-)       ",
    "   <leader> o      Ordered list  (1.)     ",
    "   <leader> q      Blockquote  (>)        ",
    "   <leader> x      Toggle / Create checkbox",
    "   <leader> ml     Link  [word]()         ",
    "   <leader> cb     Fenced code block  [v] ",
    "   <leader> mt     Insert table           ",
    "                                          ",
    "   NAVIGATION                             ",
    "                                          ",
    "   gl / gx         Follow link under cursor",
    "   <leader> mg     Follow link under cursor",
    "   ]]              Next heading           ",
    "   [[              Prev heading           ",
    "                                          ",
    "   TOOLS                                  ",
    "                                          ",
    "   <leader> mp     Toggle Markdown Preview ",
    "   <leader> mP     Stop Markdown Preview   ",
    "   <leader> mw     Word / line / char count",
    "   <leader> mc     Choose highlight color ",
    "                                          ",
    "   CLIPBOARD                              ",
    "                                          ",
    "   <leader> P      Paste from Android     ",
    "                                          ",
    "   Press  q  or  <Esc>  to close         ",
    "                                          ",
  }

  local width = 0
  for _, l in ipairs(lines) do width = math.max(width, #l) end
  width = math.min(width, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 4)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden  = "wipe"

  local win              = vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = math.floor((vim.o.lines - height) / 2),
    col       = math.floor((vim.o.columns - width) / 2),
    style     = "minimal",
    border    = "rounded",
    title     = "  Shortcuts ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true
  vim.wo[win].wrap       = false

  local ns               = vim.api.nvim_create_namespace("cheatsheet_hl")
  local header_lines     = { 1, 11, 22, 27, 33, 35 }
  for _, ln in ipairs(header_lines) do
    vim.api.nvim_buf_add_highlight(buf, ns, "DiagnosticInfo", ln, 0, -1)
  end
  for i, line in ipairs(lines) do
    local s, e = line:find("<leader>%s*%S+")
    if s then vim.api.nvim_buf_add_highlight(buf, ns, "Statement", i - 1, s - 1, e) end
    s, e = line:find("%]%]")
    if s then vim.api.nvim_buf_add_highlight(buf, ns, "Statement", i - 1, s - 1, e) end
    s, e = line:find("%[%[")
    if s then vim.api.nvim_buf_add_highlight(buf, ns, "Statement", i - 1, s - 1, e) end
  end

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      vim.api.nvim_win_close(win, true)
    end, { buffer = buf, nowait = true, silent = true })
  end
end, { desc = "Show shortcuts cheatsheet" })

-- Insert Semicolon at End of Line
vim.keymap.set("n", "<leader>;", "A;<esc>", { desc = "Append semicolon at EOL" })
vim.keymap.set("i", "<A-;>", "<c-o>A;", { desc = "Append semicolon at EOL" })

-- Unicode Catalogue & Input Layer
vim.keymap.set("n", "<leader>U", function()
  local ok, cat = pcall(require, "coop.unicode_catalogue")
  if ok then cat.open() else vim.notify("Unicode catalogue module missing", vim.log.levels.WARN) end
end, { desc = "Unicode Catalogue" })

local function unicode_layer()
  local was_insert = vim.fn.mode() == "i"
  if was_insert then vim.cmd("stopinsert") end

  local sbuf = vim.api.nvim_create_buf(false, true)
  vim.bo[sbuf].bufhidden = "wipe"
  local swin

  local hl_ns = vim.api.nvim_create_namespace("unicode_layer_hl")

  local function render(digits)
    local slots = digits .. string.rep("·", 4 - #digits)
    local preview = ""
    if #digits > 0 then
      local cp = tonumber(digits, 16)
      if cp then preview = "  →  " .. vim.fn.nr2char(cp) end
    end
    local hint = "  hex · <Enter> insert · <Esc> cancel  "
    local left = "  UNICODE  u" .. slots .. preview
    local pad  = math.max(0, vim.o.columns - #left - #hint)
    local bar  = left .. string.rep(" ", pad) .. hint

    vim.api.nvim_buf_set_lines(sbuf, 0, -1, false, { bar })
    vim.api.nvim_buf_clear_namespace(sbuf, hl_ns, 0, -1)
    local u_start = #"  UNICODE  "
    vim.api.nvim_buf_add_highlight(sbuf, hl_ns, "DiagnosticOk", 0, 0, u_start)
    vim.api.nvim_buf_add_highlight(sbuf, hl_ns, "IncSearch", 0, u_start, u_start + 1 + #digits)
    vim.api.nvim_buf_add_highlight(sbuf, hl_ns, "Comment", 0, u_start + 1 + #digits, -1)
  end

  render("")

  swin = vim.api.nvim_open_win(sbuf, false, {
    relative  = "editor",
    row       = vim.o.lines - 2,
    col       = 0,
    width     = vim.o.columns,
    height    = 1,
    style     = "minimal",
    focusable = false,
    zindex    = 250,
  })
  vim.wo[swin].winhl = "Normal:PmenuSel,NormalFloat:PmenuSel"
  vim.cmd("redraw")

  local digits  = ""
  local result  = nil

  local key_bs  = vim.api.nvim_replace_termcodes("<BS>", true, true, true)
  local key_bk  = vim.api.nvim_replace_termcodes("<Backspace>", true, true, true)
  local key_del = vim.api.nvim_replace_termcodes("<Del>", true, true, true)

  while true do
    local ok, c = pcall(vim.fn.getcharstr)
    if not ok then break end

    if c == "\27" then
      break
    elseif c == "\r" or c == "\n" then
      if #digits > 0 then
        local cp = tonumber(digits, 16)
        if cp then result = vim.fn.nr2char(cp) end
      end
      break
    elseif (c == "\8" or c == "\127" or c == "\b" or c == key_bs or c == key_bk or c == key_del or c == "\27[3~") then
      if #digits > 0 then
        digits = digits:sub(1, -2)
      end
    elseif c:match("[0-9a-fA-F]") and #digits < 4 then
      digits = digits .. c:lower()
    end

    render(digits)
    vim.cmd("redraw")
  end

  pcall(vim.api.nvim_win_close, swin, true)
  vim.cmd("redraw")

  if result then
    if was_insert then
      vim.cmd("startinsert")
      vim.api.nvim_feedkeys(result, "n", false)
    else
      vim.api.nvim_put({ result }, "c", false, true)
    end
  elseif was_insert then
    vim.cmd("startinsert")
  end
end

vim.keymap.set({ "n", "i" }, "<C-q>", unicode_layer, { desc = "Unicode input layer (hex)" })

-- ── Keymap Search Catalogue ───────────────────────────────────────────────
vim.keymap.set("n", "<leader>k", function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope not loaded", vim.log.levels.WARN)
    return
  end

  local entry_display = require("telescope.pickers.entry_display")
  local utils = require("telescope.utils")
  local make_entry = require("telescope.make_entry")

  local displayer = entry_display.create({
    separator = " ▏ ",
    items = {
      { width = 6 },
      { width = 28 },
      { width = 2 },
      { remaining = true },
    },
  })

  local mode_hl_map = {
    n = "DiagnosticInfo",
    v = "DiagnosticWarn",
    x = "DiagnosticWarn",
    i = "DiagnosticOk",
    c = "DiagnosticHint",
    t = "Special",
    o = "Type",
  }

  local custom_entry_maker = function(entry)
    local desc = ""
    if entry.callback and not entry.desc then
      desc = require("telescope.actions.utils")._get_anon_function_name(debug.getinfo(entry.callback))
    else
      desc = utils.if_nil(entry.desc, entry.rhs or ""):gsub("\n", "\\n")
    end

    local lhs = utils.display_termcodes(entry.lhs)
    local attr = ""
    if entry.noremap ~= 0 then attr = attr .. "*" end
    if entry.buffer ~= 0 then attr = attr .. "@" end

    local raw_mode = (entry.mode or " "):gsub("%s+", "")
    local m_str = "[" .. raw_mode .. "]"
    local m_hl = mode_hl_map[raw_mode] or "Title"

    return make_entry.set_default_entry_mt({
      value = entry,
      ordinal = (entry.mode or "") .. " " .. lhs .. " " .. desc,
      display = function(_)
        return displayer({
          { m_str, m_hl },
          { lhs,   "Special" },
          { attr,  "Comment" },
          { desc,  "Normal" },
        })
      end,
    }, {})
  end

  builtin.keymaps({
    prompt_title = "Active Keymaps Catalogue",
    entry_maker = custom_entry_maker,
  })
end, { desc = "Search active keymaps catalogue" })

vim.keymap.set("n", "<leader>ck", function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if ok then
    builtin.live_grep({
      prompt_title = "Config Keymap Definitions",
      search_dirs = { vim.fn.stdpath("config") },
      default_text = "keymap.set",
    })
  else
    vim.notify("Telescope not loaded", vim.log.levels.WARN)
  end
end, { desc = "Search keymaps in config files" })
