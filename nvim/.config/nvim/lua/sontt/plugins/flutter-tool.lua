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
      renameFilesWithClasses = "prompt",
      enableSnippets = true,
      updateImportsOnRename = true,
    },
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
  },
}
require("telescope").load_extension("flutter")
return M
