-- ============================================================================
-- Auto Commands
-- Automated behaviors that enhance the editing experience
-- ============================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ============================================================================
-- General Editor Behavior
-- ============================================================================

-- Highlight yanked text briefly
autocmd('TextYankPost', {
  group = augroup('HighlightYank', { clear = true }),
  callback = function()
    vim.hl.on_yank({
      higroup = 'IncSearch',
      timeout = 300,
    })
  end,
  desc = 'Highlight yanked text',
})

-- Remove trailing whitespace on save
autocmd('BufWritePre', {
  group = augroup('TrimWhitespace', { clear = true }),
  callback = function()
    local save_cursor = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
  end,
  desc = 'Remove trailing whitespace before saving',
})

-- Return to last edit position when opening files
autocmd('BufReadPost', {
  group = augroup('LastPosition', { clear = true }),
  callback = function(args)
    local valid_line = vim.fn.line([["']]) >= 1 and vim.fn.line([["']]) < vim.fn.line('$')
    local not_commit = vim.b[args.buf].filetype ~= 'commit'

    if valid_line and not_commit then
      vim.cmd([[normal! g`"]])
    end
  end,
  desc = 'Return to last edit position when opening files',
})

-- ============================================================================
-- File Type Specific Behavior
-- ============================================================================

-- Enable spell checking for text files
autocmd('FileType', {
  group = augroup('SpellCheck', { clear = true }),
  pattern = { 'gitcommit', 'markdown', 'text', 'tex' },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = 'en_us'
  end,
  desc = 'Enable spell checking for text files',
})

-- Set wrap and linebreak for text files
autocmd('FileType', {
  group = augroup('TextWrap', { clear = true }),
  pattern = { 'markdown', 'text', 'tex' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
  desc = 'Enable text wrapping for text files',
})

-- Use 2 spaces for certain file types
autocmd('FileType', {
  group = augroup('IndentTwo', { clear = true }),
  pattern = {
    'lua', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact',
    'json', 'yaml', 'html', 'css', 'scss', 'vue', 'svelte'
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
  desc = 'Use 2 spaces for web development files',
})

-- ============================================================================
-- Window and Buffer Management
-- ============================================================================

-- Automatically resize splits when terminal is resized
autocmd('VimResized', {
  group = augroup('ResizeSplits', { clear = true }),
  callback = function()
    vim.cmd('tabdo wincmd =')
  end,
  desc = 'Automatically resize splits when terminal is resized',
})

-- Close certain file types with 'q'
autocmd('FileType', {
  group = augroup('QuickClose', { clear = true }),
  pattern = {
    'qf', 'help', 'man', 'notify', 'lspinfo', 'startuptime',
    'checkhealth', 'fugitive', 'git'
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true })
  end,
  desc = 'Close certain buffers with q',
})

-- Prevent accidental writes to buffers that shouldn't be edited
autocmd({ 'BufRead', 'BufNewFile' }, {
  group = augroup('PreventEdit', { clear = true }),
  pattern = { '/tmp/*', '*.tmp', '*.bak' },
  callback = function()
    vim.opt_local.readonly = true
    vim.opt_local.modifiable = false
  end,
  desc = 'Prevent editing of temporary/backup files',
})

-- ============================================================================
-- LSP and Diagnostics (enhanced when LSP is added)
-- ============================================================================

-- Show line diagnostics automatically in hover window
autocmd({ 'CursorHold', 'CursorHoldI' }, {
  group = augroup('DiagnosticFloat', { clear = true }),
  callback = function()
    -- Only show if there are diagnostics on the current line
    local line_diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
    if #line_diagnostics > 0 then
      vim.diagnostic.open_float(nil, { focus = false, scope = 'line' })
    end
  end,
  desc = 'Show line diagnostics in hover window',
})

-- ============================================================================
-- Performance Optimizations
-- ============================================================================

-- Large file optimizations
autocmd('BufReadPre', {
  group = augroup('LargeFile', { clear = true }),
  callback = function(args)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 1024 * 1024 then -- 1MB
      vim.b[args.buf].large_file = true
      vim.opt_local.eventignore:append({
        'FileType',
        'Syntax',
        'BufEnter',
        'BufWinEnter',
        'BufRead',
        'BufNewFile',
      })
      vim.opt_local.undolevels = -1
      vim.opt_local.undoreload = 0
      vim.opt_local.list = false
    end
  end,
  desc = 'Optimize settings for large files',
})

-- ============================================================================
-- Visual Enhancements
-- ============================================================================

-- Create directory when saving new file
autocmd('BufWritePre', {
  group = augroup('CreateDir', { clear = true }),
  callback = function(event)
    if event.match:match('^%w%w+://') then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
  desc = 'Create directory when saving new file',
})

-- Turn off paste mode when leaving insert mode
autocmd('InsertLeave', {
  group = augroup('PasteMode', { clear = true }),
  callback = function()
    if vim.o.paste then
      vim.o.paste = false
    end
  end,
  desc = 'Turn off paste mode when leaving insert mode',
})

-- ============================================================================
-- Terminal Enhancements
-- ============================================================================

-- Start terminal in insert mode
autocmd('TermOpen', {
  group = augroup('TerminalMode', { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.cmd('startinsert')
  end,
  desc = 'Terminal mode optimizations',
})

-- ============================================================================
-- Plugin Integration Preparations
-- ============================================================================

-- These autocmds will be enhanced when specific plugins are added

-- Telescope integration preparation
local telescope_group = augroup('TelescopeIntegration', { clear = true })

-- LSP integration preparation
local lsp_group = augroup('LspIntegration', { clear = true })

-- Treesitter integration preparation
local treesitter_group = augroup('TreesitterIntegration', { clear = true })

-- ============================================================================
-- Notes for Future Development
-- ============================================================================

--[[
Autocmd organization:
- General editor behavior (highlighting, whitespace, positioning)
- File type specific settings (indentation, spell check, wrapping)
- Window/buffer management (resizing, quick close)
- Performance optimizations (large files)
- Visual enhancements (directory creation, paste mode)
- Terminal improvements
- Plugin integration hooks (prepared for future use)

This structure provides a solid foundation that can be extended as plugins are added.
--]]