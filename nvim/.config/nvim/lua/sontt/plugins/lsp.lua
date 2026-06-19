local M = {}

-- Capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Set capabilities globally for all servers
vim.lsp.config('*', {
  capabilities = M.capabilities,
})

-- Keymaps via LspAttach (replaces per-server on_attach)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local nmap = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
  end,
})

-- Auto format on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.lua', '*.dart', '*.py' },
  callback = function()
    vim.lsp.buf.format()
  end,
  desc = 'Auto format on save',
})

-- Setup neovim lua configuration
require('neodev').setup()

-- Mason
require('mason').setup()
require('mason-lspconfig').setup {
  -- mason-lspconfig v2 auto-enables installed servers by default
  ensure_installed = { 'lua_ls', 'pyright', 'yamlls' },
}

-- Server-specific configs
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim', 'hs' } },
      workspace = {
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
          ['/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/'] = true,
        },
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config('yamlls', {
  settings = {
    yaml = {
      schemas = {
        kubernetes = 'k8s-*.yaml',
        ['http://json.schemastore.org/github-workflow'] = '.github/workflows/*',
        ['http://json.schemastore.org/github-action'] = '.github/action.{yml,yaml}',
        ['http://json.schemastore.org/ansible-stable-2.9'] = 'roles/tasks/**/*.{yml,yaml}',
        ['http://json.schemastore.org/prettierrc'] = '.prettierrc.{yml,yaml}',
        ['http://json.schemastore.org/kustomization'] = 'kustomization.{yml,yaml}',
        ['http://json.schemastore.org/chart'] = 'Chart.{yml,yaml}',
        ['http://json.schemastore.org/circleciconfig'] = '.circleci/**/*.{yml,yaml}',
      },
    },
  },
})

vim.lsp.config('solargraph', {
  cmd = { os.getenv('HOME') .. '/.rvm/gems/ruby-2.7.6/bin/solargraph', 'stdio' },
  root_dir = function(fname)
    return vim.fs.root(fname, { 'Gemfile', '.git' })
  end,
  settings = {
    solargraph = {
      autoformat = false,
      formatting = false,
      completion = true,
      diagnostic = true,
      folding = true,
      references = true,
      rename = true,
      symbols = true,
    },
  },
})
vim.lsp.enable('solargraph')

-- rustaceanvim manages rust_analyzer automatically (no setup call needed)

return M
