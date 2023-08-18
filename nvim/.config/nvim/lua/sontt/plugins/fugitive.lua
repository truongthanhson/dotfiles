vim.keymap.set('n', '<leader>gs', [[:Git<CR>]], { desc = 'git status' })
vim.keymap.set('n', 'gh', [[:diffget //2<CR>]], { desc = 'get changes from local' })
vim.keymap.set('n', 'gl', [[:diffget //3<CR>]], { desc = 'get changes from remote' })
