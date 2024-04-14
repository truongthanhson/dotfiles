require("obsidian").setup({
  workspaces = {
    {
      name = "Work",
      path = "~/Documents/MyNotes",
    },
  },
})
vim.keymap.set("n", "gf", function()
  if require("obsidian").util.cursor_on_markdown_link() then
    return "<cmd>ObsidianFollowLink<CR>"
  else
    return "gf"
  end
end, { noremap = false, expr = true })

vim.keymap.set('n', '<leader>fn', [[:ObsidianSearch<CR>]], { desc = 'Search my notes' })
vim.keymap.set('n', '<leader>nn', [[:ObsidianNew<CR>]], { desc = 'Create new note' })
