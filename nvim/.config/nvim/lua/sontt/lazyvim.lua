local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',          opts = {} },
  {
    -- Adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    -- priority = 1000,
    -- config = function()
    --   vim.cmd.colorscheme 'rose-pine'
    -- end,
  },
  {
    'cocopon/iceberg.vim',
    -- priority = 1000,
    -- config = function()
    --   vim.cmd.colorscheme 'iceberg'
    -- end,
  },
  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    -- priority = 1000,
    -- config = function()
    --   vim.cmd.colorscheme 'onedark'
    -- end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'catppuccin'
    end,
  },
  -- {
  --   "tanvirtin/monokai.nvim",
  --   -- priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme 'monokai'
  --   end,
  -- },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    -- opts = {
    --   options = {
    --     icons_enabled = false,
    --     theme = 'gruvbox',
    --     component_separators = '|',
    --     section_separators = '',
    --   },
    -- },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    opts = {
      char = '┊',
      show_trailing_blankline_indent = false,
    },
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim',         opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', version = '*', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
    -- Treesitter context
    {
      'nvim-treesitter/nvim-treesitter-context'
    },
    -- TSPlayground
    {
      'nvim-treesitter/playground'
    },
    {
      "nvim-neotest/neotest",
      keys = {
        {
          "<leader>tNF",
          "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>",
          desc =
          "Debug File"
        },
        {
          "<leader>tNL",
          "<cmd>lua require('neotest').run.run_last({strategy = 'dap'})<cr>",
          desc =
          "Debug Last"
        },
        {
          "<leader>tNa",
          "<cmd>lua require('neotest').run.attach()<cr>",
          desc =
          "Attach"
        },
        {
          "<leader>tNf",
          "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>",
          desc =
          "File"
        },
        {
          "<leader>tNl",
          "<cmd>lua require('neotest').run.run_last()<cr>",
          desc =
          "Last"
        },
        {
          "<leader>tNn",
          "<cmd>lua require('neotest').run.run()<cr>",
          desc =
          "Nearest"
        },
        {
          "<leader>tNN",
          "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
          desc =
          "Debug Nearest"
        },
        {
          "<leader>tNo",
          "<cmd>lua require('neotest').output.open({ enter = true })<cr>",
          desc =
          "Output"
        },
        {
          "<leader>tNs",
          "<cmd>lua require('neotest').run.stop()<cr>",
          desc =
          "Stop"
        },
        {
          "<leader>tNS",
          "<cmd>lua require('neotest').summary.toggle()<cr>",
          desc =
          "Summary"
        },
      },
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "antoinemadec/FixCursorHold.nvim",
        'sidlatau/neotest-dart',
      },
      config = function()
        require('neotest').setup({
          adapters = {
            require('neotest-dart') {
              command = 'flutter',
              use_lsp = true
            },
          },
          -- overseer.nvim
          consumers = {
            overseer = require "neotest.consumers.overseer",
          },
          overseer = {
            enabled = true,
            force_default = true,
          },
        })
      end
    },
    {
      "stevearc/overseer.nvim",
      keys = {
        { "<leader>toR", "<cmd>OverseerRunCmd<cr>",       desc = "Run Command" },
        { "<leader>toa", "<cmd>OverseerTaskAction<cr>",   desc = "Task Action" },
        { "<leader>tob", "<cmd>OverseerBuild<cr>",        desc = "Build" },
        { "<leader>toc", "<cmd>OverseerClose<cr>",        desc = "Close" },
        { "<leader>tod", "<cmd>OverseerDeleteBundle<cr>", desc = "Delete Bundle" },
        { "<leader>tol", "<cmd>OverseerLoadBundle<cr>",   desc = "Load Bundle" },
        { "<leader>too", "<cmd>OverseerOpen<cr>",         desc = "Open" },
        { "<leader>toq", "<cmd>OverseerQuickAction<cr>",  desc = "Quick Action" },
        { "<leader>tor", "<cmd>OverseerRun<cr>",          desc = "Run" },
        { "<leader>tos", "<cmd>OverseerSaveBundle<cr>",   desc = "Save Bundle" },
        { "<leader>tot", "<cmd>OverseerToggle<cr>",       desc = "Toggle" },
      },
      config = true,
    },
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below automatically adds your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  --
  --    An additional note is that if you only copied in the `init.lua`, you can just comment this line
  --    to get rid of the warning telling you that there are not plugins in `lua/custom/plugins/`.
  --  { import = 'custom.plugins' },

  -- plugin for flutter developement
  {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
  },
  {
    'dart-lang/dart-vim-plugin',
  },
  {
    'christoomey/vim-tmux-navigator',
  },
  {
    'nvim-tree/nvim-tree.lua'
  },
  {
    'nvim-tree/nvim-web-devicons'
  },
  -- {
  --   'xiyaowong/transparent.nvim'
  -- },
  {
    'mbbill/undotree'
  },
  {
    'ThePrimeagen/harpoon',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    }
  },
  -- { 'github/copilot.vim', },
  -- {
  --   'zbirenbaum/copilot.lua',
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   config = function()
  --     require('copilot').setup({
  --       suggestion = { enabled = false },
  --       panel = { enabled = false },
  --     })
  --   end,
  -- },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   after = { "copilot.lua" },
  --   config = function()
  --     require("copilot_cmp").setup()
  --   end
  -- },
  { 'akinsho/toggleterm.nvim', version = "*", config = true },
  {
    'morhetz/gruvbox',
    -- priority = 1000,
    -- config = function()
    --   vim.cmd.colorscheme 'gruvbox'
    -- end,
  },
  {
    'drewtempelmeyer/palenight.vim',
  },

}, {})
