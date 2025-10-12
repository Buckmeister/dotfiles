-- ============================================================================
-- Neovim Options & Settings
-- Clean, modern defaults for a pleasant editing experience
-- ============================================================================

local opt = vim.opt
local g = vim.g

-- ============================================================================
-- UI & Appearance
-- ============================================================================

opt.termguicolors = true -- Enable 24-bit RGB colors
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.signcolumn = "yes" -- Always show sign column (prevents text shifting)
opt.cursorline = true -- Highlight current line
opt.wrap = false -- Don't wrap long lines
opt.scrolloff = 8 -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
opt.colorcolumn = "80,100" -- Visual guides at 80 and 100 characters
opt.list = true -- Show whitespace characters
opt.listchars = { -- Define which whitespace to show
  tab = "▸ ",
  trail = "·",
  extends = "❯",
  precedes = "❮",
  nbsp = "⦸",
}

-- ============================================================================
-- Editor Behavior
-- ============================================================================

opt.mouse = "a" -- Enable mouse in all modes
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.undofile = true -- Persistent undo history
opt.backup = false -- Don't create backup files (we have git!)
opt.writebackup = false -- Don't create backup while editing
opt.swapfile = false -- Disable swap files (modern SSDs are fast)
opt.updatetime = 250 -- Faster completion and diagnostics
opt.timeoutlen = 300 -- Faster key sequence completion
opt.confirm = true -- Ask for confirmation instead of failing

-- ============================================================================
-- Indentation & Formatting
-- ============================================================================

opt.tabstop = 4 -- Number of spaces a tab represents
opt.shiftwidth = 4 -- Number of spaces for auto-indentation
opt.softtabstop = 4 -- Number of spaces for tab in insert mode
opt.expandtab = true -- Convert tabs to spaces
opt.autoindent = true -- Copy indent from current line to new line
opt.smartindent = true -- Smart auto-indentation
opt.breakindent = true -- Wrapped lines maintain indentation
opt.linebreak = true -- Break lines at word boundaries

-- ============================================================================
-- Search & Navigation
-- ============================================================================

opt.ignorecase = true -- Ignore case in search patterns
opt.smartcase = true -- Override ignorecase if search has uppercase
opt.hlsearch = true -- Highlight search results
opt.incsearch = true -- Show search matches as you type
opt.inccommand = "split" -- Preview substitutions in split window

-- ============================================================================
-- Splits & Windows
-- ============================================================================

opt.splitbelow = true -- New horizontal splits go below
opt.splitright = true -- New vertical splits go to the right
opt.winminheight = 0 -- Allow windows to be fully collapsed
opt.winminwidth = 0 -- Allow windows to be fully collapsed
opt.equalalways = false -- Don't auto-resize windows

-- ============================================================================
-- Completion & Wildmenu
-- ============================================================================

opt.completeopt = "menu,menuone,noselect" -- Better completion experience
opt.wildmode = "longest:full,full" -- Command-line completion behavior
opt.wildoptions = "pum" -- Use popup menu for completion
opt.pumheight = 10 -- Limit popup menu height

-- ============================================================================
-- Performance
-- ============================================================================

opt.lazyredraw = false -- Don't redraw during macros (disabled for modern Neovim)
opt.synmaxcol = 300 -- Limit syntax highlighting for very long lines
opt.updatetime = 250 -- Faster CursorHold events

-- ============================================================================
-- Language-Specific Settings
-- ============================================================================

-- Use 2 spaces for specific file types
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript", "typescript", "json", "yaml", "html", "css" },
  callback = function()
    opt.tabstop = 2
    opt.shiftwidth = 2
    opt.softtabstop = 2
  end,
})

-- ============================================================================
-- Neovim-Specific Settings
-- ============================================================================

-- Set up dedicated Python environment for Neovim
local nvim_python = vim.fn.expand("~/.local/bin/nvim-python3")
if vim.fn.executable(nvim_python) == 1 then
  g.python3_host_prog = nvim_python
else
  -- Fallback to system python3
  g.python3_host_prog = vim.fn.exepath("python3")
end

-- Disable some built-in plugins we don't need
local disabled_built_ins = {
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit", -- We'll use a better alternative
}

for _, plugin in pairs(disabled_built_ins) do
  g["loaded_" .. plugin] = 1
end

