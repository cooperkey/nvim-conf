return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "codecompanion" },
    opts = {
      file_types = { "markdown", "codecompanion" },
      completions = {
        blink = { enabled = true },
      },
      heading = {
        sign = false,
        width = "full",
        position = "overlay",
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        sign = true,
        width = "block",
        left_pad = 2,
        right_pad = 2,
        min_width = 40,
        border = "thin",
      },
      pipe_table = {
        style = "full",
        cell = "padded",
      },
      checkbox = {
        bullet = false,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
          cancelled = { raw = "[~]", rendered = "󰅖 ", highlight = "RenderMarkdownError" },
          important = { raw = "[!]", rendered = "󰅾 ", highlight = "RenderMarkdownWarn" },
        },
      },
      latex = {
        enabled = true,
        render_modes = false,
        converter = "latex2text",
        inline = true,
        block = true,
        highlight = "RenderMarkdownMath",
        position = "center",
        top_pad = 0,
        bottom_pad = 0,
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0
    end,
    ft = { "markdown" },
  },
}
