local M = {}
local lsp = require('sontt.plugins.lsp')
require("flutter-tools").setup {
  outline = { auto_open = false },
  decorations = {
    statusline = { device = true, app_version = true },
  },
  widget_guides = { enabled = true, debug = true },
  dev_log = { enabled = true, open_cmd = "tabedit" },
  lsp = {
    color = {
      enabled = true,
      background = true,
      virtual_text = false,
    },
    settings = {
      showTodos = true,
      analysisExcludedFolders = {
        vim.fn.expand("$HOME/.pub-cache/"),
      },
      renameFilesWithClasses = "prompt",
      enableSnippets = true,
      updateImportsOnRename = true,
    },
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
  },
}
vim.keymap.set('n', '<leader>fc', [[<Cmd>lua require('telescope').extensions.flutter.commands()<CR>]],
  { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fl', [[<Cmd>FlutterLogClear<CR>]],
  { noremap = true, desc = "Open Flutter log and clear" })
require("telescope").load_extension("flutter")
return M
