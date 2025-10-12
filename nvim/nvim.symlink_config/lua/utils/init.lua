-- ============================================================================
-- Utility Functions
-- Helper functions for configuration and customization
-- ============================================================================

local M = {}

-- ============================================================================
-- Configuration Helpers
-- ============================================================================

--- Check if a plugin is available
---@param plugin string The plugin name
---@return boolean
function M.has_plugin(plugin)
  return pcall(require, plugin)
end

--- Safe require with error handling
---@param module string The module to require
---@return any|nil
function M.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify('Failed to load module: ' .. module, vim.log.levels.ERROR)
    return nil
  end
  return result
end

-- ============================================================================
-- UI Helpers
-- ============================================================================

--- Create a bordered window
---@param title string Window title
---@param content table Content lines
function M.create_float(title, content)
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = title,
    title_pos = 'center',
  }

  vim.api.nvim_open_win(buf, true, opts)
end

-- ============================================================================
-- File System Helpers
-- ============================================================================

--- Check if a file exists
---@param path string File path
---@return boolean
function M.file_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == 'file'
end

--- Check if a directory exists
---@param path string Directory path
---@return boolean
function M.dir_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == 'directory'
end

--- Get the project root directory
---@return string|nil
function M.get_project_root()
  local markers = { '.git', 'package.json', 'Cargo.toml', 'go.mod', 'pyproject.toml' }
  local path = vim.fn.expand('%:p:h')

  while path ~= '/' do
    for _, marker in ipairs(markers) do
      if M.file_exists(path .. '/' .. marker) or M.dir_exists(path .. '/' .. marker) then
        return path
      end
    end
    path = vim.fn.fnamemodify(path, ':h')
  end

  return nil
end

-- ============================================================================
-- LSP Helpers
-- ============================================================================

--- Check if LSP is attached to current buffer
---@return boolean
function M.lsp_attached()
  return #vim.lsp.get_active_clients({ bufnr = 0 }) > 0
end

--- Get active LSP clients for current buffer
---@return table
function M.get_lsp_clients()
  return vim.lsp.get_active_clients({ bufnr = 0 })
end

-- ============================================================================
-- Diagnostic Helpers
-- ============================================================================

--- Get diagnostic count for current buffer
---@return table
function M.get_diagnostic_count()
  local diagnostics = vim.diagnostic.get(0)
  local count = { error = 0, warn = 0, info = 0, hint = 0 }

  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      count.error = count.error + 1
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      count.warn = count.warn + 1
    elseif diagnostic.severity == vim.diagnostic.severity.INFO then
      count.info = count.info + 1
    elseif diagnostic.severity == vim.diagnostic.severity.HINT then
      count.hint = count.hint + 1
    end
  end

  return count
end

-- ============================================================================
-- Theme Helpers
-- ============================================================================

--- Toggle between dark and light theme
function M.toggle_theme()
  if vim.o.background == 'dark' then
    vim.o.background = 'light'
  else
    vim.o.background = 'dark'
  end
end

-- ============================================================================
-- Keymap Helpers
-- ============================================================================

--- Create a keymap with better defaults
---@param mode string|table Mode or modes
---@param lhs string Left-hand side
---@param rhs string|function Right-hand side
---@param opts table|nil Options
function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ============================================================================
-- Configuration Info
-- ============================================================================

--- Show configuration information
function M.show_config_info()
  local info = {
    '🎵 lua.loves.nvim - Reborn Configuration Info 🎵',
    '',
    'Neovim Version: ' .. vim.version().major .. '.' .. vim.version().minor .. '.' .. vim.version().patch,
    'Config Path: ' .. vim.fn.stdpath('config'),
    'Data Path: ' .. vim.fn.stdpath('data'),
    'Cache Path: ' .. vim.fn.stdpath('cache'),
    '',
    'LSP Status: ' .. (M.lsp_attached() and 'Attached' or 'Not attached'),
    'Project Root: ' .. (M.get_project_root() or 'Not in project'),
    '',
    'Available Commands:',
    '  :Lazy - Plugin manager',
    '  :Mason - LSP server manager',
    '  :checkhealth - Neovim health check',
    '  :Telescope - Fuzzy finder',
    '',
    'Press q to close this window',
  }

  M.create_float('Configuration Info', info)

  -- Allow closing with 'q'
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = true, silent = true })
end

-- Create command for config info
vim.api.nvim_create_user_command('ConfigInfo', M.show_config_info, {})

return M