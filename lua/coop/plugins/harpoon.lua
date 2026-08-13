return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
        },
      })

      vim.keymap.set("n", "<leader>a", function()
        local file = vim.api.nvim_buf_get_name(0)
        if file == "" or vim.bo.buftype ~= "" then
          vim.notify("Cannot harpoon unnamed or special buffer", vim.log.levels.WARN)
          return
        end
        harpoon:list():add()
        vim.notify("󰛢 Harpooned: " .. vim.fn.fnamemodify(file, ":t"), vim.log.levels.INFO)
      end, { desc = "Harpoon add file" })

      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
      vim.keymap.set("n", "<M-a>", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
      vim.keymap.set("n", "<M-r>", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
      vim.keymap.set("n", "<M-s>", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
      vim.keymap.set("n", "<M-t>", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
    end,
  },
}
