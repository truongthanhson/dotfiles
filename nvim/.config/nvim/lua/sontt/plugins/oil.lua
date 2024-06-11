require("oil").setup({
  keymaps = {
    ["<C-p>"] = false,
    ["<leader>pv"] = "actions.preview",
  },
  view_options = {
    -- Show files and directories that start with "."
    show_hidden = true,
  },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<C-b>", "<CMD>Oil<CR>", { desc = "Open parent directory" })
