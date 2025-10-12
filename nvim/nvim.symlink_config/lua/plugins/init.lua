-- ============================================================================
-- Plugin Manager - lazy.nvim
-- Modern, fast plugin manager with lazy loading capabilities
-- ============================================================================

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  print('Installing lazy.nvim...')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Plugin Specifications
-- ============================================================================

require('lazy').setup({
  -- Import plugin modules
  { import = 'plugins.ui' },          -- UI enhancements (colorscheme, statusline, etc.)
  { import = 'plugins.editor' },      -- Editor functionality (file explorer, fuzzy finder, etc.)
  { import = 'plugins.lsp' },         -- Language Server Protocol configuration
  { import = 'plugins.tools' },       -- Development tools (git, terminal, etc.)
}, {
  -- ============================================================================
  -- Lazy.nvim Configuration
  -- ============================================================================

  defaults = {
    lazy = true,                      -- Enable lazy loading by default
    version = false,                  -- Don't pin to specific versions (use latest)
  },

  install = {
    missing = true,                   -- Install missing plugins on startup
    colorscheme = { 'habamax' },      -- Try these colorschemes during installation
  },

  checker = {
    enabled = true,                   -- Check for plugin updates
    notify = false,                   -- Don't notify about updates (reduces noise)
    frequency = 3600,                 -- Check every hour
  },

  change_detection = {
    enabled = true,                   -- Automatically check for config changes
    notify = false,                   -- Don't notify about changes (reduces noise)
  },

  ui = {
    size = { width = 0.8, height = 0.8 },
    wrap = true,
    border = 'rounded',
    backdrop = 60,
    title = '🎵 lua.loves.nvim - Plugin Manager',
    title_pos = 'center',
    icons = {
      cmd = ' ',
      config = '',
      event = '',
      ft = ' ',
      init = ' ',
      import = ' ',
      keys = ' ',
      lazy = '󰒲 ',
      loaded = '●',
      not_loaded = '○',
      plugin = ' ',
      runtime = ' ',
      require = '󰢱 ',
      source = ' ',
      start = '',
      task = '✔ ',
      list = {
        '●',
        '➜',
        '★',
        '‒',
      },
    },
  },

  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})

-- ============================================================================
-- Plugin Manager Keymaps
-- ============================================================================

vim.keymap.set('n', '<leader>L', '<cmd>Lazy<CR>', { desc = 'Open Lazy plugin manager' })
vim.keymap.set('n', '<leader>Li', '<cmd>Lazy install<CR>', { desc = 'Install plugins' })
vim.keymap.set('n', '<leader>Lu', '<cmd>Lazy update<CR>', { desc = 'Update plugins' })
vim.keymap.set('n', '<leader>Ls', '<cmd>Lazy sync<CR>', { desc = 'Sync plugins' })
vim.keymap.set('n', '<leader>Lc', '<cmd>Lazy check<CR>', { desc = 'Check for plugin updates' })
vim.keymap.set('n', '<leader>Ll', '<cmd>Lazy log<CR>', { desc = 'Show plugin log' })
vim.keymap.set('n', '<leader>Lp', '<cmd>Lazy profile<CR>', { desc = 'Show plugin profile' })

-- ============================================================================
-- Welcome Message
-- ============================================================================

-- Show a friendly message on first setup
if vim.fn.argc() == 0 and not vim.g.started_by_firenvim then
  vim.defer_fn(function()
    vim.api.nvim_echo({
      { '🎵 Welcome to lua.loves.nvim! 🎵\n', 'Title' },
      { 'Your modern Neovim configuration is ready.\n\n', 'Comment' },
      { 'Key commands:\n', 'Normal' },
      { '  <Space>L  - Open plugin manager\n', 'Comment' },
      { '  <Space>?  - Show keymaps (when which-key is added)\n', 'Comment' },
      { '  :help     - Neovim help system\n', 'Comment' },
      { '  :checkhealth - Check Neovim health\n\n', 'Comment' },
      { 'Happy coding! 💙', 'Title' },
    }, false, {})
  end, 200)
end