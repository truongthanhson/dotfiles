vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

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

-- vim fugitive keymaps
vim.keymap.set('n', '<leader>gs', [[:Git<CR>]], { desc = 'git status' })
vim.keymap.set('n', 'gh', [[:diffget //2<CR>]], { desc = 'get changes from local' })
vim.keymap.set('n', 'gl', [[:diffget //3<CR>]], { desc = 'get changes from remote' })

-- cool keymaps from ThePrimeagen
vim.keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })
vim.keymap.set('n', 'n', 'nzzzv', { noremap = true, silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { noremap = true, silent = true })

-- Telescope
-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
--vim.keymap.set('n', '<leader>se', require('telescope.builtin').diagnostics({ severity = vim.diagnostic.severity.ERROR }),
--{ desc = '[S]earch Diagnostics [E]rrors' })
vim.keymap.set('n', '<leader>fd', function()
  require('telescope.builtin').diagnostics({

    severity = vim.diagnostic.severity.ERROR

  })
end, { desc = '[Telescope]: Find diagnostics' })
-- Treesitter
-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Flutter tools
vim.keymap.set('n', '<leader>fc', [[<Cmd>lua require('telescope').extensions.flutter.commands()<CR>]],
  { noremap = true, silent = true })

-- nvim-tree
vim.keymap.set('n', '<C-b>', [[:NvimTreeToggle<CR>]], { desc = '[?] Toggle Nvim Tree' })

-- vim.keymap.set('n', '<C-b>', [[:Ex<CR>]], { desc = 'Open Netrw Explorer' })

-- Harpoon
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

-- scripts
vim.keymap.set('n', '<F5>', [[:lua RunDart()<CR>]], { noremap = true, desc = 'run current dart file' })
vim.keymap.set('n', '<F4>', [[:lua RunC()<CR>]], { noremap = true, desc = 'run current cpp file', silent = true })
