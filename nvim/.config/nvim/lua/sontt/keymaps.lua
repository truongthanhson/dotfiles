vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- [[ Basic Keymaps ]]
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("v", "p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "<C-f>", "<cmd>!tmux neww ~/.local/scripts/tmux_sessionizer<CR>")

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', '<leader>hl', [[:nohl<CR>]], { desc = 'clear highlight search' })
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
vim.keymap.set('n', '<leader>qq', [[:q<CR>]], { noremap = true, desc = 'quit', silent = true })

-- cool keymaps from ThePrimeagen
vim.keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })
vim.keymap.set('n', 'n', 'nzzzv', { noremap = true, silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { noremap = true, silent = true })
-- easy go full screen
vim.keymap.set('n', '<leader>_', '<C-w>_<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>|', '<C-w>|<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-b>', [[:Ex<CR>]], { desc = 'Open Netrw Explorer' })

-- quickfix list navigate keymap
vim.keymap.set('n', '<leader>nh', "<cmd>cnext<CR>zz", { desc = "Forward qfixlist" })
vim.keymap.set('n', '<leader>nq', "<cmd>cprev<CR>zz", { desc = "Backward qfixlist" })

-- shortcut to copy current filename/filepath to clipboard
vim.keymap.set("n", "<leader>cf", "<cmd>let @+ = expand(\"%\")<CR>", { desc = "Copy File Name" })
vim.keymap.set("n", "<leader>cp", "<cmd>let @+ = expand(\"%:p\")<CR>", { desc = "Copy File Path" })


-- scripts
vim.keymap.set('n', '<F6>',
  [[:exec '!g++-13 -std=c++0x -DLOCAL -o "%<" "%"' | :vsplit | term "./%<" && rm "./%<"<CR><CR> | :startinsert<CR>]],
  { noremap = true, desc = 'run current cpp file & wait for input', silent = true })
vim.keymap.set({ 'n', 'i' }, '<F5>',
  [[:vsplit | term dart run "%"<CR> | :startinsert<CR>]],
  { noremap = true, desc = 'dart run', silent = true })
