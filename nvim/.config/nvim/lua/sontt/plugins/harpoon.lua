require("harpoon").setup({})

vim.keymap.set('n', '<leader><space>', [[:lua require("harpoon.ui").toggle_quick_menu()<CR>]],
  { desc = 'toggle Harpoon quick menu' })
vim.keymap.set('n', '<leader>ba', [[:lua require("harpoon.mark").add_file()<CR>]],
  { desc = 'add file to Harpoon quick menu' })
vim.keymap.set('n', '<leader>br', [[:lua require("harpoon.mark").rm_file()<CR>]],
  { desc = 'remove file from Harpoon quick menu' })
vim.keymap.set('n', '<leader>bcl', [[:lua require("harpoon.mark").clear_all()<CR>]],
  { desc = 'clear all files in harppon quick menu' })
vim.keymap.set('n', '<leader>1', [[:lua require("harpoon.ui").nav_file(1)<CR>]],
  { desc = 'quick navigate to file 1' })
vim.keymap.set('n', '<leader>2', [[:lua require("harpoon.ui").nav_file(2)<CR>]],
  { desc = 'quick navigate to file 2' })
vim.keymap.set('n', '<leader>3', [[:lua require("harpoon.ui").nav_file(3)<CR>]],
  { desc = 'quick navigate to file 3' })
vim.keymap.set('n', '<leader>4', [[:lua require("harpoon.ui").nav_file(4)<CR>]],
  { desc = 'quick navigate to file 4' })
vim.keymap.set('n', '<leader>5', [[:lua require("harpoon.ui").nav_file(5)<CR>]],
  { desc = 'quick navigate to file 5' })
vim.keymap.set('n', '<leader>6', [[:lua require("harpoon.ui").nav_file(6)<CR>]],
  { desc = 'quick navigate to file 6' })
