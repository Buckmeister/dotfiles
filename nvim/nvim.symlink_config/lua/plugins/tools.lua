-- ============================================================================
-- Development Tools
-- Git integration, terminal enhancements, and workflow improvements
-- ============================================================================

return {
  -- ============================================================================
  -- Git Integration - Gitsigns (Lightweight and Fast)
  -- ============================================================================
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('gitsigns').setup({
        signs = {
          add          = { text = '│' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true
        },
        attach_to_untracked = true,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = 'Next git hunk' })

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = 'Previous git hunk' })

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
          map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
          map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = 'Stage hunk' })
          map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { desc = 'Reset hunk' })
          map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage buffer' })
          map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
          map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset buffer' })
          map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
          map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = 'Blame line' })
          map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'Toggle line blame' })
          map('n', '<leader>hd', gs.diffthis, { desc = 'Diff this' })
          map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = 'Diff this ~' })
          map('n', '<leader>td', gs.toggle_deleted, { desc = 'Toggle deleted' })

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select hunk' })
        end
      })
    end,
  },

  -- ============================================================================
  -- Which Key - Keymap Helper (v3 Configuration)
  -- ============================================================================
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      delay = 300,
      expand = 1,
      notify = false,

      -- Key group specifications
      spec = {
        { '<leader>b', group = 'buffer', icon = '󰓩' },
        { '<leader>e', group = 'extras', icon = '󰒃' },
        { '<leader>f', group = 'find', icon = '󰈞' },
        { '<leader>g', group = 'git', icon = '󰊢' },
        { '<leader>h', group = 'git hunks', icon = '󰊢' },
        { '<leader>l', group = 'lsp', icon = '󰌘' },
        { '<leader>L', group = 'lazy', icon = '󰒲' },
        { '<leader>s', group = 'search', icon = '󰍉' },
        { '<leader>t', group = 'toggle', icon = '󰔡' },
        { '<leader>w', group = 'window', icon = '󰖳' },
        { '<leader>d', group = 'diagnostics', icon = '󰙵' },
      },

      -- Icons configuration
      icons = {
        breadcrumb = '»',
        separator = '➜',
        group = '+',
        ellipsis = '…',
        rules = false,
        colors = true,
        keys = {
          Up = ' ',
          Down = ' ',
          Left = ' ',
          Right = ' ',
          C = '󰘴 ',
          M = '󰘵 ',
          D = '󰘳 ',
          S = '󰘶 ',
          CR = '󰌑 ',
          Esc = '󱊷 ',
          ScrollWheelDown = '󱕐 ',
          ScrollWheelUp = '󱕑 ',
          NL = '󰌑 ',
          BS = '󰁮',
          Space = '󱁐 ',
          Tab = '󰌒 ',
          F1 = '󱊫',
          F2 = '󱊬',
          F3 = '󱊭',
          F4 = '󱊮',
          F5 = '󱊯',
          F6 = '󱊰',
          F7 = '󱊱',
          F8 = '󱊲',
          F9 = '󱊳',
          F10 = '󱊴',
          F11 = '󱊵',
          F12 = '󱊶',
        },
      },

      -- Window appearance
      win = {
        border = 'rounded',
        padding = { 1, 2 },
        wo = {
          winblend = 0,
        },
      },

      -- Layout settings
      layout = {
        spacing = 3,
        align = 'left',
      },

      -- Key filtering
      filter = function(mapping)
        return mapping.desc and mapping.desc ~= ""
      end,

      -- Sort alphabetically for better navigation
      sort = { "key" },

      -- Enable built-in key mappings for basic vim operations
      triggers = {
        { '<auto>', mode = 'nxso' },
      },
    },

    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show({ global = false })
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },

    config = function(_, opts)
      vim.o.timeout = true
      vim.o.timeoutlen = 300

      local wk = require('which-key')
      wk.setup(opts)
    end,
  },

  -- ============================================================================
  -- Comment Enhancement
  -- ============================================================================
  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      -- Ensure treesitter-context-commentstring is set up
      require('ts_context_commentstring').setup({
        enable_autocmd = false,
      })

      require('Comment').setup({
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end,
  },

  -- ============================================================================
  -- Terminal Integration - ToggleTerm
  -- ============================================================================
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    cmd = { 'ToggleTerm', 'TermExec' },
    keys = {
      { '<leader>tt', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },
      { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', desc = 'Toggle floating terminal' },
      { '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', desc = 'Toggle horizontal terminal' },
      { '<leader>tv', '<cmd>ToggleTerm direction=vertical size=80<cr>', desc = 'Toggle vertical terminal' },
    },
    config = function()
      require('toggleterm').setup({
        size = function(term)
          if term.direction == 'horizontal' then
            return 15
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = 'float',
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = 'curved',
          winblend = 0,
          highlights = {
            border = 'Normal',
            background = 'Normal',
          },
        },
      })
    end,
  },

  -- ============================================================================
  -- Placeholder for Additional Development Tools
  -- ============================================================================
  -- These will be added as we discuss specific needs:
  -- - Git client (fugitive, neogit, or lazygit integration)
  -- - Project management tools
  -- - Task runners
  -- - Documentation generators
  -- - Code snippets (LuaSnip configuration)
  -- - Session management
  -- - Database integration
  -- - REST client
  -- - Note-taking integration
}