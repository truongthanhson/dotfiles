local M = {}
local lsp = require('sontt.plugins.lsp')
require("flutter-tools").setup {
  fvm = true,
  outline = { auto_open = false },
  decorations = {
    -- app_version reads pubspec.yaml via expand('%:p:h'); breaks when the
    -- active buffer is an oil:// dir buffer (ENOENT oil:/.../pubspec.yaml).
    statusline = { device = true, app_version = false },
  },
  widget_guides = { enabled = true, debug = true },
  dev_log = { enabled = true, open_cmd = "tabedit" },
  debugger = { -- integrate with nvim dap + install dart code debugger
    enabled = false,
    evaluate_to_string_in_debug_views = true,
  },
  -- fvm = true,
  lsp = {
    settings = {
      showTodos = true,
      analysisExcludedFolders = {
        vim.fn.expand("$HOME/.pub-cache/"),
        vim.fn.expand("$HOME/devtools/flutter/"),
        vim.fn.expand("$HOME/projects/sakani-v4-mobile/test/"),
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
