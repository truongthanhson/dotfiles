local M = {}
vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
require("telescope").load_extension("live_grep_args")
return M
