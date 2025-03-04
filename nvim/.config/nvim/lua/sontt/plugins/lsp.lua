local M = {}
M.on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local servers = {
  clangd = {},
  kotlin_language_server = {},
  gopls = {},
  terraformls = {},
  rust_analyzer = {},
  lua_ls = {
    Lua = {
      diagnostics = {
        globals = { 'vim', 'hs' }
      },
      workspace = {
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
          ['/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/'] = true,
        },
        checkThirdParty = false
      },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.lua", "*.dart" },
  callback = function()
    vim.lsp.buf.format()
  end,
  desc = "Auto format on save",
})
-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}
local opts = {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = opts.capabilities,
      on_attach = opts.on_attach,
      settings = servers[server_name],

    }
  end,
}
require("lspconfig").yamlls.setup {
  settings = {
    yaml = {
      schemas = {
        kubernetes = "k8s-*.yaml",
        ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
        ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
        ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/**/*.{yml,yaml}",
        ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
        ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
        ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
        ["http://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}",
      },
    },
  },
}
require 'lspconfig'.terraformls.setup {}
require 'lspconfig'.rust_analyzer.setup {}
require 'lspconfig'.solargraph.setup {}
require 'lspconfig'.solargraph.setup {
  -- cmd = { os.getenv( "HOME" ) .. "/.rvm/shims/solargraph", 'stdio' },
  cmd = { os.getenv("HOME") .. "/.rvm/gems/ruby-2.7.6/bin/solargraph", 'stdio' },
  root_dir = require 'lspconfig'.util.root_pattern("Gemfile", ".git", "."),
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  settings = {
    solargraph = {
      autoformat = false,
      formatting = false,
      completion = true,
      diagnostic = true,
      folding = true,
      references = true,
      rename = true,
      symbols = true
    }
  }
}
require 'lspconfig'.clangd.setup {

  on_attach = M.on_attach,
  capabilities = M.capabilities,
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_dir = require 'lspconfig'.util.root_pattern(
    '.clangd'
    , '.clang-tidy'
    , '.clang-format'
    , 'compile_commands.json'
    , 'compile_flags.txt'
    , 'configure.ac'
    , '.git'
  ),
  single_file_support = true,
}

require 'lspconfig'.rust_analyzer.setup {
  require("rust-tools").setup {}
}

return M
