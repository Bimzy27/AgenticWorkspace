local map = vim.keymap.set

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Escape
map('i', 'jk', '<Esc>')
map('i', 'kj', '<Esc>')

-- Better window navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Resize windows
map('n', '<C-Up>', ':resize +2<CR>')
map('n', '<C-Down>', ':resize -2<CR>')
map('n', '<C-Left>', ':vertical resize -2<CR>')
map('n', '<C-Right>', ':vertical resize +2<CR>')

-- Move lines up/down
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")

-- Keep cursor centered when scrolling
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

-- Better paste (don't overwrite register)
map('v', 'p', '"_dP')

-- Clear search highlight
map('n', '<Esc>', ':nohlsearch<CR>')

-- Quickfix navigation
map('n', '<leader>qo', ':copen<CR>', { desc = 'Open quickfix' })
map('n', '<leader>qc', ':cclose<CR>', { desc = 'Close quickfix' })
map('n', ']q', ':cnext<CR>', { desc = 'Next quickfix' })
map('n', '[q', ':cprev<CR>', { desc = 'Prev quickfix' })

-- Buffer navigation
map('n', '<S-l>', ':bnext<CR>')
map('n', '<S-h>', ':bprevious<CR>')
map('n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete buffer' })

-- Save
map('n', '<C-s>', ':w<CR>')
map('i', '<C-s>', '<Esc>:w<CR>')

-- Splits
map('n', '<leader>sv', ':vsplit<CR>', { desc = 'Vertical split' })
map('n', '<leader>sh', ':split<CR>', { desc = 'Horizontal split' })
map('n', '<leader>sc', ':close<CR>', { desc = 'Close split' })

-- Diagnostics
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
map('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
