-- ============================================================================
-- Key Mappings
-- Thoughtful, ergonomic key bindings for efficient editing
-- ============================================================================

local map = vim.keymap.set

-- ============================================================================
-- Better Defaults
-- ============================================================================

-- Clear search highlighting
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Better up/down movement for wrapped lines
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Better indenting (maintains selection in visual mode)
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Move selected lines up/down
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")

-- Keep cursor centered during search and page movements
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')

-- Better paste (doesn't overwrite clipboard in visual mode)
map('x', '<leader>p', [["_dP]], { desc = 'Paste without overwriting clipboard' })

-- ============================================================================
-- Leader Key Mappings (Space)
-- ============================================================================

-- File operations
map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Save file' })
map('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quit' })
map('n', '<leader>Q', '<cmd>qall<CR>', { desc = 'Quit all' })

-- Buffer operations
map('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })
map('n', '<leader>ba', '<cmd>%bdelete<CR>', { desc = 'Delete all buffers' })

-- Quick actions
map('n', '<leader>/', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('n', '<leader>r', '<cmd>source %<CR>', { desc = 'Reload current file' })

-- Custom shortcuts (migrated from previous config)
map('n', '<leader>a', '<cmd>Alpha<CR>', { desc = 'Open Alpha dashboard' })
map('n', '<leader>x', '<cmd>Bdelete<CR>', { desc = 'Close buffer' })
map('n', '<leader>j', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
map('n', '<leader>k', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<leader>b', '<cmd>BufferLinePick<CR>', { desc = 'Pick buffer' })
map('n', '<leader>o', '<cmd>only<CR>', { desc = 'Only current window' })
map('n', '<leader>u', '<cmd>update<CR>', { desc = 'Save file' })
map('n', '<leader>w', '<cmd>wincmd w<CR>', { desc = 'Switch windows' })
map('n', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
map('n', '<leader>Y', 'gg"+yG', { desc = 'Yank entire buffer to clipboard' })
map('v', '<leader>y', '"+y', { desc = 'Yank selection to system clipboard' })

-- Extras group (from old config)
map('n', '<leader>ef', '<cmd>Telescope file_browser<cr>', { desc = 'Telescope file browser' })
map('n', '<leader>en', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle file tree' })

-- ============================================================================
-- Window Management
-- ============================================================================

-- Easier window navigation
map('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Window resizing
map('n', '<C-Up>', '<cmd>resize +2<CR>', { desc = 'Increase window height' })
map('n', '<C-Down>', '<cmd>resize -2<CR>', { desc = 'Decrease window height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<CR>', { desc = 'Decrease window width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<CR>', { desc = 'Increase window width' })

-- Window splits
map('n', '<leader>sv', '<cmd>vsplit<CR>', { desc = 'Split vertically' })
map('n', '<leader>sh', '<cmd>split<CR>', { desc = 'Split horizontally' })
map('n', '<leader>se', '<C-w>=', { desc = 'Equalize splits' })
map('n', '<leader>sx', '<cmd>close<CR>', { desc = 'Close current split' })

-- ============================================================================
-- Tab Management
-- ============================================================================

map('n', '<leader>to', '<cmd>tabnew<CR>', { desc = 'Open new tab' })
map('n', '<leader>tx', '<cmd>tabclose<CR>', { desc = 'Close tab' })
map('n', '<leader>tn', '<cmd>tabnext<CR>', { desc = 'Next tab' })
map('n', '<leader>tp', '<cmd>tabprevious<CR>', { desc = 'Previous tab' })

-- ============================================================================
-- Text Manipulation
-- ============================================================================

-- Join lines but keep cursor position
map('n', 'J', 'mzJ`z')

-- Duplicate line or selection
map('n', '<leader>d', 'yyp', { desc = 'Duplicate line' })
map('v', '<leader>d', 'y`>p', { desc = 'Duplicate selection' })

-- Select all
map('n', '<C-a>', 'ggVG', { desc = 'Select all' })

-- Replace word under cursor
map('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Replace word under cursor' })

-- ============================================================================
-- Terminal Mode
-- ============================================================================

-- Easier escape from terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Terminal window navigation
map('t', '<C-h>', '<cmd>wincmd h<CR>', { desc = 'Move to left window' })
map('t', '<C-j>', '<cmd>wincmd j<CR>', { desc = 'Move to bottom window' })
map('t', '<C-k>', '<cmd>wincmd k<CR>', { desc = 'Move to top window' })
map('t', '<C-l>', '<cmd>wincmd l<CR>', { desc = 'Move to right window' })

-- ============================================================================
-- Quick Commands
-- ============================================================================

-- Toggle options
map('n', '<leader>tw', '<cmd>set wrap!<CR>', { desc = 'Toggle line wrap' })
map('n', '<leader>tn', '<cmd>set number!<CR>', { desc = 'Toggle line numbers' })
map('n', '<leader>tr', '<cmd>set relativenumber!<CR>', { desc = 'Toggle relative numbers' })
map('n', '<leader>ts', '<cmd>set spell!<CR>', { desc = 'Toggle spell check' })

-- Diagnostic mappings (will be enhanced when LSP is added)
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
map('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Diagnostics to location list' })

-- ============================================================================
-- Plugin-Specific Mappings (to be added as plugins are installed)
-- ============================================================================

-- Placeholder section for plugin mappings
-- These will be moved to their respective plugin configuration files

-- Example structure:
-- map('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = 'Find files' })
-- map('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = 'Live grep' })
-- map('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })

-- ============================================================================
-- Notes for Future Development
-- ============================================================================

--[[
Key mapping conventions used in this config:

<leader> = Space key
- <leader>f* = File/Find operations (Telescope)
- <leader>g* = Git operations
- <leader>l* = LSP operations
- <leader>b* = Buffer operations
- <leader>t* = Toggle operations or Tab operations
- <leader>s* = Search/Replace operations
- <leader>w* = Window/Workspace operations
- <leader>d* = Debug operations (when added)

This structure provides room for growth while maintaining logical groupings.
--]]