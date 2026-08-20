-- ── Unicode Catalogue ─────────────────────────────────────────────────────
-- Browsable floating window of common unicode characters.
-- j/k to navigate, <CR> to insert at cursor, y to yank, q/<Esc> to close.

local M = {}

local categories = {
  {
    name = "Latin Extended",
    chars = {
      { char = "ñ", code = "00F1", name = "Latin Small Letter N with Tilde" },
      { char = "Ñ", code = "00D1", name = "Latin Capital Letter N with Tilde" },
      { char = "á", code = "00E1", name = "Latin Small Letter A with Acute" },
      { char = "é", code = "00E9", name = "Latin Small Letter E with Acute" },
      { char = "í", code = "00ED", name = "Latin Small Letter I with Acute" },
      { char = "ó", code = "00F3", name = "Latin Small Letter O with Acute" },
      { char = "ú", code = "00FA", name = "Latin Small Letter U with Acute" },
      { char = "Á", code = "00C1", name = "Latin Capital Letter A with Acute" },
      { char = "É", code = "00C9", name = "Latin Capital Letter E with Acute" },
      { char = "Í", code = "00CD", name = "Latin Capital Letter I with Acute" },
      { char = "Ó", code = "00D3", name = "Latin Capital Letter O with Acute" },
      { char = "Ú", code = "00DA", name = "Latin Capital Letter U with Acute" },
      { char = "à", code = "00E0", name = "Latin Small Letter A with Grave" },
      { char = "è", code = "00E8", name = "Latin Small Letter E with Grave" },
      { char = "ì", code = "00EC", name = "Latin Small Letter I with Grave" },
      { char = "ò", code = "00F2", name = "Latin Small Letter O with Grave" },
      { char = "ù", code = "00F9", name = "Latin Small Letter U with Grave" },
      { char = "ü", code = "00FC", name = "Latin Small Letter U with Diaeresis" },
      { char = "ö", code = "00F6", name = "Latin Small Letter O with Diaeresis" },
      { char = "ä", code = "00E4", name = "Latin Small Letter A with Diaeresis" },
      { char = "â", code = "00E2", name = "Latin Small Letter A with Circumflex" },
      { char = "ê", code = "00EA", name = "Latin Small Letter E with Circumflex" },
      { char = "î", code = "00EE", name = "Latin Small Letter I with Circumflex" },
      { char = "ô", code = "00F4", name = "Latin Small Letter O with Circumflex" },
      { char = "û", code = "00FB", name = "Latin Small Letter U with Circumflex" },
      { char = "ç", code = "00E7", name = "Latin Small Letter C with Cedilla" },
      { char = "Ç", code = "00C7", name = "Latin Capital Letter C with Cedilla" },
      { char = "ß", code = "00DF", name = "Latin Small Letter Sharp S" },
      { char = "æ", code = "00E6", name = "Latin Small Letter AE" },
      { char = "œ", code = "0153", name = "Latin Small Letter OE" },
      { char = "ø", code = "00F8", name = "Latin Small Letter O with Stroke" },
      { char = "å", code = "00E5", name = "Latin Small Letter A with Ring Above" },
    },
  },
  {
    name = "Punctuation & Typography",
    chars = {
      { char = "…", code = "2026", name = "Horizontal Ellipsis" },
      { char = "—", code = "2014", name = "Em Dash" },
      { char = "–", code = "2013", name = "En Dash" },
      { char = "\u{201C}", code = "201C", name = "Left Double Quotation Mark" },
      { char = "\u{201D}", code = "201D", name = "Right Double Quotation Mark" },
      { char = "\u{2018}", code = "2018", name = "Left Single Quotation Mark" },
      { char = "\u{2019}", code = "2019", name = "Right Single Quotation Mark" },
      { char = "«", code = "00AB", name = "Left Double Angle Quotation Mark" },
      { char = "»", code = "00BB", name = "Right Double Angle Quotation Mark" },
      { char = "•", code = "2022", name = "Bullet" },
      { char = "·", code = "00B7", name = "Middle Dot" },
      { char = "§", code = "00A7", name = "Section Sign" },
      { char = "¶", code = "00B6", name = "Pilcrow Sign" },
      { char = "†", code = "2020", name = "Dagger" },
      { char = "‡", code = "2021", name = "Double Dagger" },
      { char = "™", code = "2122", name = "Trade Mark Sign" },
      { char = "©", code = "00A9", name = "Copyright Sign" },
      { char = "®", code = "00AE", name = "Registered Sign" },
    },
  },
  {
    name = "Currency",
    chars = {
      { char = "€", code = "20AC", name = "Euro Sign" },
      { char = "£", code = "00A3", name = "Pound Sign" },
      { char = "¥", code = "00A5", name = "Yen Sign" },
      { char = "¢", code = "00A2", name = "Cent Sign" },
      { char = "₱", code = "20B1", name = "Philippine Peso Sign" },
      { char = "₩", code = "20A9", name = "Won Sign" },
      { char = "₹", code = "20B9", name = "Indian Rupee Sign" },
      { char = "₿", code = "20BF", name = "Bitcoin Sign" },
      { char = "₺", code = "20BA", name = "Turkish Lira Sign" },
      { char = "₴", code = "20B4", name = "Hryvnia Sign" },
    },
  },
  {
    name = "Math & Logic",
    chars = {
      { char = "±", code = "00B1", name = "Plus-Minus Sign" },
      { char = "×", code = "00D7", name = "Multiplication Sign" },
      { char = "÷", code = "00F7", name = "Division Sign" },
      { char = "≠", code = "2260", name = "Not Equal To" },
      { char = "≤", code = "2264", name = "Less-Than or Equal To" },
      { char = "≥", code = "2265", name = "Greater-Than or Equal To" },
      { char = "≈", code = "2248", name = "Almost Equal To" },
      { char = "∞", code = "221E", name = "Infinity" },
      { char = "√", code = "221A", name = "Square Root" },
      { char = "∑", code = "2211", name = "N-Ary Summation" },
      { char = "∏", code = "220F", name = "N-Ary Product" },
      { char = "∫", code = "222B", name = "Integral" },
      { char = "∂", code = "2202", name = "Partial Differential" },
      { char = "∆", code = "2206", name = "Increment" },
      { char = "∇", code = "2207", name = "Nabla" },
      { char = "∈", code = "2208", name = "Element Of" },
      { char = "∉", code = "2209", name = "Not an Element Of" },
      { char = "∅", code = "2205", name = "Empty Set" },
      { char = "⊂", code = "2282", name = "Subset Of" },
      { char = "⊃", code = "2283", name = "Superset Of" },
      { char = "∩", code = "2229", name = "Intersection" },
      { char = "∪", code = "222A", name = "Union" },
      { char = "¬", code = "00AC", name = "Not Sign" },
      { char = "∧", code = "2227", name = "Logical And" },
      { char = "∨", code = "2228", name = "Logical Or" },
      { char = "⊕", code = "2295", name = "Circled Plus" },
      { char = "°", code = "00B0", name = "Degree Sign" },
      { char = "π", code = "03C0", name = "Greek Small Letter Pi (Math)" },
      { char = "μ", code = "03BC", name = "Greek Small Letter Mu (Micro)" },
    },
  },
  {
    name = "Arrows",
    chars = {
      { char = "→", code = "2192", name = "Rightwards Arrow" },
      { char = "←", code = "2190", name = "Leftwards Arrow" },
      { char = "↑", code = "2191", name = "Upwards Arrow" },
      { char = "↓", code = "2193", name = "Downwards Arrow" },
      { char = "↔", code = "2194", name = "Left Right Arrow" },
      { char = "↕", code = "2195", name = "Up Down Arrow" },
      { char = "⇒", code = "21D2", name = "Rightwards Double Arrow" },
      { char = "⇐", code = "21D0", name = "Leftwards Double Arrow" },
      { char = "⇔", code = "21D4", name = "Left Right Double Arrow" },
      { char = "⟹", code = "27F9", name = "Long Rightwards Double Arrow" },
      { char = "⟺", code = "27FA", name = "Long Left Right Double Arrow" },
      { char = "↗", code = "2197", name = "North East Arrow" },
      { char = "↘", code = "2198", name = "South East Arrow" },
      { char = "↖", code = "2196", name = "North West Arrow" },
      { char = "↙", code = "2199", name = "South West Arrow" },
    },
  },
  {
    name = "Greek Letters",
    chars = {
      { char = "α", code = "03B1", name = "Greek Small Letter Alpha" },
      { char = "β", code = "03B2", name = "Greek Small Letter Beta" },
      { char = "γ", code = "03B3", name = "Greek Small Letter Gamma" },
      { char = "δ", code = "03B4", name = "Greek Small Letter Delta" },
      { char = "ε", code = "03B5", name = "Greek Small Letter Epsilon" },
      { char = "ζ", code = "03B6", name = "Greek Small Letter Zeta" },
      { char = "η", code = "03B7", name = "Greek Small Letter Eta" },
      { char = "θ", code = "03B8", name = "Greek Small Letter Theta" },
      { char = "λ", code = "03BB", name = "Greek Small Letter Lambda" },
      { char = "ν", code = "03BD", name = "Greek Small Letter Nu" },
      { char = "ξ", code = "03BE", name = "Greek Small Letter Xi" },
      { char = "ρ", code = "03C1", name = "Greek Small Letter Rho" },
      { char = "σ", code = "03C3", name = "Greek Small Letter Sigma" },
      { char = "τ", code = "03C4", name = "Greek Small Letter Tau" },
      { char = "φ", code = "03C6", name = "Greek Small Letter Phi" },
      { char = "χ", code = "03C7", name = "Greek Small Letter Chi" },
      { char = "ψ", code = "03C8", name = "Greek Small Letter Psi" },
      { char = "ω", code = "03C9", name = "Greek Small Letter Omega" },
      { char = "Γ", code = "0393", name = "Greek Capital Letter Gamma" },
      { char = "Δ", code = "0394", name = "Greek Capital Letter Delta" },
      { char = "Θ", code = "0398", name = "Greek Capital Letter Theta" },
      { char = "Λ", code = "039B", name = "Greek Capital Letter Lambda" },
      { char = "Ξ", code = "039E", name = "Greek Capital Letter Xi" },
      { char = "Π", code = "03A0", name = "Greek Capital Letter Pi" },
      { char = "Σ", code = "03A3", name = "Greek Capital Letter Sigma" },
      { char = "Φ", code = "03A6", name = "Greek Capital Letter Phi" },
      { char = "Ψ", code = "03A8", name = "Greek Capital Letter Psi" },
      { char = "Ω", code = "03A9", name = "Greek Capital Letter Omega" },
    },
  },
  {
    name = "Box Drawing",
    chars = {
      { char = "─", code = "2500", name = "Box Drawings Light Horizontal" },
      { char = "│", code = "2502", name = "Box Drawings Light Vertical" },
      { char = "┌", code = "250C", name = "Box Drawings Light Down and Right" },
      { char = "┐", code = "2510", name = "Box Drawings Light Down and Left" },
      { char = "└", code = "2514", name = "Box Drawings Light Up and Right" },
      { char = "┘", code = "2518", name = "Box Drawings Light Up and Left" },
      { char = "├", code = "251C", name = "Box Drawings Light Vertical and Right" },
      { char = "┤", code = "2524", name = "Box Drawings Light Vertical and Left" },
      { char = "┬", code = "252C", name = "Box Drawings Light Down and Horizontal" },
      { char = "┴", code = "2534", name = "Box Drawings Light Up and Horizontal" },
      { char = "┼", code = "253C", name = "Box Drawings Light Vertical and Horizontal" },
      { char = "═", code = "2550", name = "Box Drawings Double Horizontal" },
      { char = "║", code = "2551", name = "Box Drawings Double Vertical" },
      { char = "╔", code = "2554", name = "Box Drawings Double Down and Right" },
      { char = "╗", code = "2557", name = "Box Drawings Double Down and Left" },
      { char = "╚", code = "255A", name = "Box Drawings Double Up and Right" },
      { char = "╝", code = "255D", name = "Box Drawings Double Up and Left" },
      { char = "░", code = "2591", name = "Light Shade" },
      { char = "▒", code = "2592", name = "Medium Shade" },
      { char = "▓", code = "2593", name = "Dark Shade" },
      { char = "█", code = "2588", name = "Full Block" },
    },
  },
  {
    name = "Symbols & Icons",
    chars = {
      { char = "★", code = "2605", name = "Black Star" },
      { char = "☆", code = "2606", name = "White Star" },
      { char = "♥", code = "2665", name = "Black Heart Suit" },
      { char = "♦", code = "2666", name = "Black Diamond Suit" },
      { char = "♣", code = "2663", name = "Black Club Suit" },
      { char = "♠", code = "2660", name = "Black Spade Suit" },
      { char = "☑", code = "2611", name = "Ballot Box with Check" },
      { char = "☐", code = "2610", name = "Ballot Box" },
      { char = "✓", code = "2713", name = "Check Mark" },
      { char = "✗", code = "2717", name = "Ballot X" },
      { char = "⚠", code = "26A0", name = "Warning Sign" },
      { char = "◆", code = "25C6", name = "Black Diamond" },
      { char = "◇", code = "25C7", name = "White Diamond" },
      { char = "○", code = "25CB", name = "White Circle" },
      { char = "●", code = "25CF", name = "Black Circle" },
      { char = "□", code = "25A1", name = "White Square" },
      { char = "■", code = "25A0", name = "Black Square" },
      { char = "▶", code = "25B6", name = "Black Right-Pointing Triangle" },
      { char = "◀", code = "25C0", name = "Black Left-Pointing Triangle" },
      { char = "▲", code = "25B2", name = "Black Up-Pointing Triangle" },
      { char = "▼", code = "25BC", name = "Black Down-Pointing Triangle" },
    },
  },
  {
    name = "Superscripts",
    chars = {
      { char = "⁰", code = "2070", name = "Superscript Zero" },
      { char = "¹", code = "00B9", name = "Superscript One" },
      { char = "²", code = "00B2", name = "Superscript Two" },
      { char = "³", code = "00B3", name = "Superscript Three" },
      { char = "⁴", code = "2074", name = "Superscript Four" },
      { char = "⁵", code = "2075", name = "Superscript Five" },
      { char = "⁶", code = "2076", name = "Superscript Six" },
      { char = "⁷", code = "2077", name = "Superscript Seven" },
      { char = "⁸", code = "2078", name = "Superscript Eight" },
      { char = "⁹", code = "2079", name = "Superscript Nine" },
      { char = "⁺", code = "207A", name = "Superscript Plus Sign" },
      { char = "⁻", code = "207B", name = "Superscript Minus" },
      { char = "⁼", code = "207C", name = "Superscript Equals Sign" },
      { char = "⁽", code = "207D", name = "Superscript Left Parenthesis" },
      { char = "⁾", code = "207E", name = "Superscript Right Parenthesis" },
      { char = "ⁿ", code = "207F", name = "Superscript Latin Small Letter N" },
      { char = "ⁱ", code = "2071", name = "Superscript Latin Small Letter I" },
      { char = "ᵃ", code = "1D43", name = "Superscript Latin Small Letter A" },
      { char = "ᵇ", code = "1D47", name = "Superscript Latin Small Letter B" },
      { char = "ᶜ", code = "1D48", name = "Superscript Latin Small Letter C" },
      { char = "ᵈ", code = "1D49", name = "Superscript Latin Small Letter D" },
      { char = "ᵉ", code = "1D4B", name = "Superscript Latin Small Letter E" },
      { char = "ᵍ", code = "1D4D", name = "Superscript Latin Small Letter G" },
      { char = "ʰ", code = "02B0", name = "Modifier Letter Small H" },
      { char = "ʲ", code = "02B2", name = "Modifier Letter Small J" },
      { char = "ᵏ", code = "1D4C", name = "Superscript Latin Small Letter K" },
      { char = "ˡ", code = "02E1", name = "Modifier Letter Small L" },
      { char = "ᵐ", code = "1D50", name = "Superscript Latin Small Letter M" },
      { char = "ᵒ", code = "1D52", name = "Superscript Latin Small Letter O" },
      { char = "ᵖ", code = "1D56", name = "Superscript Latin Small Letter P" },
      { char = "ʳ", code = "02B3", name = "Modifier Letter Small R" },
      { char = "ˢ", code = "02E2", name = "Modifier Letter Small S" },
      { char = "ᵗ", code = "1D57", name = "Superscript Latin Small Letter T" },
      { char = "ᵘ", code = "1D58", name = "Superscript Latin Small Letter U" },
      { char = "ᵛ", code = "1D5B", name = "Superscript Latin Small Letter V" },
      { char = "ʷ", code = "02B7", name = "Modifier Letter Small W" },
      { char = "ˣ", code = "02E3", name = "Modifier Letter Small X" },
      { char = "ʸ", code = "02B8", name = "Modifier Letter Small Y" },
      { char = "ᶻ", code = "1D5C", name = "Superscript Latin Small Letter Z" },
    },
  },
  {
    name = "Subscripts",
    chars = {
      { char = "₀", code = "2080", name = "Subscript Zero" },
      { char = "₁", code = "2081", name = "Subscript One" },
      { char = "₂", code = "2082", name = "Subscript Two" },
      { char = "₃", code = "2083", name = "Subscript Three" },
      { char = "₄", code = "2084", name = "Subscript Four" },
      { char = "₅", code = "2085", name = "Subscript Five" },
      { char = "₆", code = "2086", name = "Subscript Six" },
      { char = "₇", code = "2087", name = "Subscript Seven" },
      { char = "₈", code = "2088", name = "Subscript Eight" },
      { char = "₉", code = "2089", name = "Subscript Nine" },
      { char = "₊", code = "208A", name = "Subscript Plus Sign" },
      { char = "₋", code = "208B", name = "Subscript Minus" },
      { char = "₌", code = "208C", name = "Subscript Equals Sign" },
      { char = "₍", code = "208D", name = "Subscript Left Parenthesis" },
      { char = "₎", code = "208E", name = "Subscript Right Parenthesis" },
      { char = "ₐ", code = "2090", name = "Subscript Latin Small Letter A" },
      { char = "ₑ", code = "2095", name = "Subscript Latin Small Letter E" },
      { char = "ₕ", code = "2096", name = "Subscript Latin Small Letter H" },
      { char = "ᵢ", code = "1D62", name = "Subscript Latin Small Letter I" },
      { char = "ⱼ", code = "2C7C", name = "Subscript Latin Small Letter J" },
      { char = "ₖ", code = "2097", name = "Subscript Latin Small Letter K" },
      { char = "ₗ", code = "2098", name = "Subscript Latin Small Letter L" },
      { char = "ₘ", code = "2099", name = "Subscript Latin Small Letter M" },
      { char = "ₙ", code = "209A", name = "Subscript Latin Small Letter N" },
      { char = "ₒ", code = "209B", name = "Subscript Latin Small Letter O" },
      { char = "ₚ", code = "209C", name = "Subscript Latin Small Letter P" },
      { char = "ᵣ", code = "1D63", name = "Subscript Latin Small Letter R" },
      { char = "ₛ", code = "209E", name = "Subscript Latin Small Letter S" },
      { char = "ₜ", code = "209D", name = "Subscript Latin Small Letter T" },
      { char = "ᵤ", code = "1D64", name = "Subscript Latin Small Letter U" },
      { char = "ᵥ", code = "1D65", name = "Subscript Latin Small Letter V" },
      { char = "ₓ", code = "208F", name = "Subscript Latin Small Letter X" },
    },
  },
}

-- ── Build flat line list ───────────────────────────────────────────────────
local function build_lines()
  local lines    = {}
  local char_map = {}   -- line index (1-based) → entry table or nil

  -- hint row at the top
  lines[#lines + 1] = "  <CR> insert   y yank   j/k navigate   q/<Esc> close"
  char_map[#lines]  = nil
  lines[#lines + 1] = ""
  char_map[#lines]  = nil

  for _, cat in ipairs(categories) do
    local sep = string.rep("─", math.max(1, 56 - #cat.name - 2))
    lines[#lines + 1] = "  ── " .. cat.name .. " " .. sep
    char_map[#lines]  = nil

    for _, entry in ipairs(cat.chars) do
      lines[#lines + 1] = string.format("  %s   U+%s   %s", entry.char, entry.code, entry.name)
      char_map[#lines]  = entry
    end

    lines[#lines + 1] = ""
    char_map[#lines]  = nil
  end

  return lines, char_map
end

-- ── Open the catalogue window ──────────────────────────────────────────────
function M.open()
  local lines, char_map = build_lines()

  local width  = 62
  local height = math.min(#lines, vim.o.lines - 4)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden  = "wipe"

  local win = vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = math.floor((vim.o.lines   - height) / 2),
    col       = math.floor((vim.o.columns - width)  / 2),
    style     = "minimal",
    border    = "rounded",
    title     = "  ◆ Unicode Catalogue ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true
  vim.wo[win].wrap       = false
  vim.wo[win].scrolloff  = 4

  -- ── Highlighting ──────────────────────────────────────────────────────
  local ns = vim.api.nvim_create_namespace("unicode_catalogue_hl")

  -- hint line
  vim.api.nvim_buf_add_highlight(buf, ns, "Comment", 0, 0, -1)

  for i, line in ipairs(lines) do
    if line:match("^  ──") then
      -- category header
      vim.api.nvim_buf_add_highlight(buf, ns, "DiagnosticInfo", i - 1, 0, -1)
    elseif char_map[i] then
      -- glyph column (bytes 2–4, the actual character)
      vim.api.nvim_buf_add_highlight(buf, ns, "IncSearch",      i - 1, 2, 5)
      -- U+XXXX
      local us = line:find("U%+")
      if us then
        vim.api.nvim_buf_add_highlight(buf, ns, "DiagnosticWarn", i - 1, us - 1, us + 5)
      end
      -- description (rest)
      local desc_s = line:find("%s+%a", 10)
      if desc_s then
        vim.api.nvim_buf_add_highlight(buf, ns, "Normal", i - 1, desc_s, -1)
      end
    end
  end

  -- ── Navigation helpers ────────────────────────────────────────────────
  local function move(dir)
    local row = vim.api.nvim_win_get_cursor(win)[1]
    local next = row + dir
    while next >= 1 and next <= #lines do
      if char_map[next] then
        vim.api.nvim_win_set_cursor(win, { next, 0 })
        return
      end
      next = next + dir
    end
  end

  local function current_entry()
    local row = vim.api.nvim_win_get_cursor(win)[1]
    return char_map[row]
  end

  local function insert_entry()
    local entry = current_entry()
    if not entry then return end
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_put({ entry.char }, "c", false, true)
    vim.notify(
      string.format("Inserted  %s  U+%s  %s", entry.char, entry.code, entry.name),
      vim.log.levels.INFO
    )
  end

  local function yank_entry()
    local entry = current_entry()
    if not entry then return end
    vim.fn.setreg('"', entry.char)
    vim.fn.setreg('+', entry.char)
    vim.notify(
      string.format("Yanked  %s  U+%s", entry.char, entry.code),
      vim.log.levels.INFO
    )
  end

  -- ── Keymaps ───────────────────────────────────────────────────────────
  local o = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "j",     function() move(1)   end,  o)
  vim.keymap.set("n", "k",     function() move(-1)  end,  o)
  vim.keymap.set("n", "<CR>",  insert_entry,               o)
  vim.keymap.set("n", "y",     yank_entry,                 o)
  vim.keymap.set("n", "q",     function() vim.api.nvim_win_close(win, true) end, o)
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, o)

  -- Jump to first char entry
  for i = 1, #lines do
    if char_map[i] then
      vim.api.nvim_win_set_cursor(win, { i, 0 })
      break
    end
  end
end

return M
