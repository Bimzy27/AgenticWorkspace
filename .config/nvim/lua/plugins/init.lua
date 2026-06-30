return {
  -- Colorscheme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = { flavour = 'mocha' },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd('colorscheme catppuccin')
    end,
  },

  -- oil.nvim: edit filesystem like a buffer
  {
    'stevearc/oil.nvim',
    lazy = false,
    keys = { { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' } },
    opts = {
      default_file_explorer = true,
      columns = { 'icon', 'size', 'mtime' },
      view_options = { show_hidden = true },
      keymaps = {
        ['<CR>'] = 'actions.select',
        ['-']    = 'actions.parent',
        ['_']    = 'actions.open_cwd',
        ['gs']   = 'actions.change_sort',
        ['g.']   = 'actions.toggle_hidden',
        ['<C-p>'] = 'actions.preview',
        ['<C-c>'] = 'actions.close',
        ['<C-r>'] = 'actions.refresh',
      },
    },
  },

  -- snacks.nvim: file finder, grep, notifications, and more
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      picker = {
        enabled = true,
        sources = { explorer = {} },
      },
    },
    keys = {
      { '<leader>ff', function() Snacks.picker.files() end,       desc = 'Find files' },
      { '<leader>fg', function() Snacks.picker.grep() end,        desc = 'Grep' },
      { '<leader>fb', function() Snacks.picker.buffers() end,     desc = 'Buffers' },
      { '<leader>fr', function() Snacks.picker.recent() end,      desc = 'Recent files' },
      { '<leader>fs', function() Snacks.picker.lsp_symbols() end, desc = 'LSP symbols' },
      { '<leader>fh', function() Snacks.picker.help() end,        desc = 'Help' },
      { '<leader>fd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
      { '<leader>fn', function() Snacks.notifier.show_history() end, desc = 'Notifications' },
    },
  },

  -- neogit: git UI
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
    },
    keys = {
      { '<leader>gg', '<CMD>Neogit<CR>',                       desc = 'Neogit' },
      { '<leader>gd', '<CMD>DiffviewOpen<CR>',                 desc = 'Diff view' },
      { '<leader>gh', '<CMD>DiffviewFileHistory %<CR>',        desc = 'File history' },
    },
    opts = {
      integrations = { diffview = true },
      signs = { hunk = { '', '' }, item = { '>', '<' }, section = { '>', '<' } },
    },
  },

  -- gitsigns: inline git blame and hunk navigation
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map('n', ']h', gs.next_hunk, 'Next hunk')
        map('n', '[h', gs.prev_hunk, 'Prev hunk')
        map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
        map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
        map('n', '<leader>hd', gs.diffthis, 'Diff this')
      end,
    },
  },

  -- Treesitter: syntax highlighting and text objects
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    opts = {
      ensure_installed = {
        'lua', 'vim', 'vimdoc', 'bash', 'markdown', 'markdown_inline',
        'python', 'javascript', 'typescript', 'tsx', 'go', 'rust', 'c',
        'json', 'yaml', 'toml', 'html', 'css',
      },
      highlight = { enable = true },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup({ ui = { border = 'rounded' } })
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'ts_ls', 'gopls', 'pyright', 'rust_analyzer' },
        handlers = {
          function(server)
            require('lspconfig')[server].setup({})
          end,
          lua_ls = function()
            require('lspconfig').lua_ls.setup({
              settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
            })
          end,
        },
      })

      vim.keymap.set('n', 'gd', vim.lsp.buf.definition,      { desc = 'Go to definition' })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references,      { desc = 'References' })
      vim.keymap.set('n', 'K',  vim.lsp.buf.hover,           { desc = 'Hover' })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,  { desc = 'Rename' })
      vim.keymap.set('n', '<leader>lf', function()
        vim.lsp.buf.format({ async = true })
      end, { desc = 'Format' })
    end,
  },

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>']   = cmp.mapping.scroll_docs(-4),
          ['<C-f>']   = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>']   = cmp.mapping.abort(),
          ['<CR>']    = cmp.mapping.confirm({ select = true }),
          ['<Tab>']   = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources(
          { { name = 'nvim_lsp' }, { name = 'luasnip' } },
          { { name = 'buffer' }, { name = 'path' } }
        ),
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end,
  },

  -- which-key: keybinding help
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {},
  },

  -- mini.pairs: auto-close brackets
  {
    'echasnovski/mini.pairs',
    event = 'InsertEnter',
    opts = {},
  },

  -- Comment.nvim
  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  -- Lualine: statusline
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = {
        theme = 'catppuccin',
        component_separators = '',
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 } },
      },
    },
  },
}
