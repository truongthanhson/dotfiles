local M = {}
function M.setup()
  require('neotest').setup({
    adapters = {
      require('neotest-dart') {
        command = 'flutter',
        use_lsp = true
      },
    },
    consumers = {
      overseer = require "neotest.consumers.overseer",
    },
    overseer = {
      enabled = true,
      force_default = true,
    },
  })
end

return M
