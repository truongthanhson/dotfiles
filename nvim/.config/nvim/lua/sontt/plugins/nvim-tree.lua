require("nvim-tree").setup()

-- disable netrw for nvimtree working properly
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.keymap.set('n', '<C-b>', [[:NvimTreeToggle<CR>]], { desc = '[?] Toggle Nvim Tree' })
