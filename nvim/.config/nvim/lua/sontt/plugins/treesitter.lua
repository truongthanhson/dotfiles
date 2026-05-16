local parsers = {
  'c', 'cpp', 'dart', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript',
  'vimdoc', 'vim', 'kotlin', 'markdown', 'markdown_inline', 'ruby', 'yaml',
}

require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath('data') .. '/site',
}

do
  local ts = require('nvim-treesitter')
  local installed = {}
  for _, p in ipairs(ts.get_installed('parsers')) do installed[p] = true end
  local missing = {}
  for _, p in ipairs(parsers) do
    if not installed[p] then table.insert(missing, p) end
  end
  if #missing > 0 then ts.install(missing) end
end

local group = vim.api.nvim_create_augroup('SonttTreesitter', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = parsers,
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
    if args.match ~= 'python' then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = { 'dart' },
  callback = function()
    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt_local.foldenable = false
  end,
})

local function tsmap(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

local function sel(query)
  return function()
    require('nvim-treesitter-textobjects.select').select_textobject(query, 'textobjects')
  end
end

local function move(fn, query)
  return function()
    require('nvim-treesitter-textobjects.move')[fn](query, 'textobjects')
  end
end

for _, m in ipairs({ 'x', 'o' }) do
  tsmap(m, 'aa', sel('@parameter.outer'), 'param outer')
  tsmap(m, 'ia', sel('@parameter.inner'), 'param inner')
  tsmap(m, 'af', sel('@function.outer'), 'function outer')
  tsmap(m, 'if', sel('@function.inner'), 'function inner')
  tsmap(m, 'ac', sel('@class.outer'),    'class outer')
  tsmap(m, 'ic', sel('@class.inner'),    'class inner')
end

for _, m in ipairs({ 'n', 'x', 'o' }) do
  tsmap(m, ']m', move('goto_next_start',     '@function.outer'), 'next function start')
  tsmap(m, ']M', move('goto_next_end',       '@function.outer'), 'next function end')
  tsmap(m, '[m', move('goto_previous_start', '@function.outer'), 'prev function start')
  tsmap(m, '[M', move('goto_previous_end',   '@function.outer'), 'prev function end')
  tsmap(m, ']]', move('goto_next_start',     '@class.outer'),    'next class start')
  tsmap(m, '][', move('goto_next_end',       '@class.outer'),    'next class end')
  tsmap(m, '[[', move('goto_previous_start', '@class.outer'),    'prev class start')
  tsmap(m, '[]', move('goto_previous_end',   '@class.outer'),    'prev class end')
end

tsmap('n', '<leader>a', function()
  require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner')
end, 'swap param next')
tsmap('n', '<leader>A', function()
  require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner')
end, 'swap param prev')

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,         { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,         { desc = 'Next diagnostic' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Floating diagnostic' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics list' })
