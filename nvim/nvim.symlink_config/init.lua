-- ============================================================================
-- lua.loves.nvim
-- A passionate Neovim configuration
-- ============================================================================

-- Ensure we're running minimum required Neovim
if vim.fn.has("nvim-0.11") == 0 then
  vim.api.nvim_echo({
    { "lua.loves.nvim requires Neovim >= 0.11.0\n", "ErrorMsg" },
    { "Please upgrade your Neovim installation\n", "WarningMsg" },
    { "Press any key to exit...", "ErrorMsg" },
  }, true, {})
  vim.fn.getchar()
  vim.cmd([[quit]])
  return
end

-- Leader key - Set this early so all mappings use it correctly
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw early (we'll use a modern file explorer)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Core configuration modules
require("config.options") -- Vim options and settings
require("config.keymaps") -- Key mappings
require("config.autocmds") -- Auto commands

-- Plugin management and configuration
require("plugins") -- All plugin management

if vim.fn.argc() == 0 then
  vim.defer_fn(function()
    vim.api.nvim_echo({
      { "🎵 lua.loves.nvim - Reborn! 🎵\n", "Title" },
    }, false, {})
  end, 100)
end
