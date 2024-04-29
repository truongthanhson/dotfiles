require("oil").setup({
  keymaps = {
    ["<C-p>"] = false,
    ["<leader>pv"] = "actions.preview",
  },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<C-b>", "<CMD>Oil<CR>", { desc = "Open parent directory" })
