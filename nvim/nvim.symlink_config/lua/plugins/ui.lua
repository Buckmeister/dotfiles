-- ============================================================================
-- UI & Visual Enhancements
-- Colorscheme, alpha dashboard, and visual improvements
-- ============================================================================

return {
  -- ============================================================================
  -- OneDark Colorscheme - Classic OneDark Theme
  -- ============================================================================
  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 1000, -- Highest priority to load first
    config = function()
      -- Configure OneDark before loading
      require('onedark').setup({
        style = 'darker',
        toggle_style_key = '<leader>tc',

        -- Custom highlights for a cohesive experience
        highlights = {
          OverLength = { fg = '$dark_red', bg = '$bg0' },
          ColorColumn = { fg = '$red', bg = '$bg1' },
          CursorLine = { bg = '$bg2' },
          DashboardHeader = { fg = '$blue', bg = '$bg0' },
          DashboardShortCut = { fg = '$dark_red', bg = '$bg1' },
          DashboardFooter = { fg = '$grey', bg = '$bg0' },
        },

        -- Enhanced diagnostics
        diagnostics = {
          darker = true,
          undercurl = true,
          background = true,
        },

        -- Code style customizations
        code_style = {
          comments = 'italic',
          keywords = 'none',
          functions = 'none',
          strings = 'none',
          variables = 'none'
        },

        -- Transparent background (optional)
        transparent = false,

        -- Terminal colors
        term_colors = true,

        -- Enhanced ending tildes
        ending_tildes = false,

        -- Better cmp styling
        cmp_itemkind_reverse = false,
      })

      -- Load the colorscheme immediately
      require('onedark').load()

      -- Ensure colorscheme is applied immediately by setting it again
      vim.cmd.colorscheme('onedark')
    end,
  },

  -- ============================================================================
  -- Alpha Dashboard - "LUA LOVES NVIM" Welcome Screen
  -- ============================================================================
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')

      -- ========================================================================
      -- Beautiful ASCII Art Header
      -- ========================================================================
      dashboard.section.header.opts.hl = 'DashboardHeader'
      dashboard.section.header.val = {
        '',
        '              ▀▀▀▀▀▀          ▀▀▀▀▀▀▀',
        '           ▀▀▀▀▀▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀▀▀▀▀▀▀▀',
        '         ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀           ▀▀▀',
        '        ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀              ▀▀',
        '       ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀              ▀▀',
        '      ▀▀▀▀▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀▀▀              ▀▀',
        '      ▀▀▀▀▀▀▀▀▀▀▀     ▀▀▀▀▀▀▀              ▀▀',
        '      ▀▀▀▀▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀▀▀              ▀▀',
        '      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀               ▀▀',
        '      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀               ▀▀',
        '       ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀               ▀▀',
        '        ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀               ▀▀▀',
        '          ▀▀▀▀▀▀▀▀▀▀▀▀▀               ▀▀▀',
        '           ▀▀▀▀▀▀▀▀▀▀▀   ▀▀▀        ▀▀▀',
        '             ▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀    ▀▀▀▀',
        '                ▀▀▀▀▀▀   ▀▀▀   ▀▀▀▀',
        '                  ▀▀▀▀▀     ▀▀▀▀',
        '                     ▀▀▀  ▀▀▀▀',
        '                       ▀▀▀▀',
        '                        ▀▀',
        '',
        '█░░ █░█ ▄▀█   █░░ █▀█ █░█ █▀▀ █▀   █▄░█ █░█ █ █▀▄▀█',
        '█▄▄ █▄█ █▀█   █▄▄ █▄█ ▀▄▀ ██▄ ▄█   █░▀█ ▀▄▀ █ █░▀░█',
        '',
        '    🎵 Reborn • Modern • Anxiety-Free • Built with Love 💙',
      }

      -- ========================================================================
      -- Modern Action Buttons (Updated for new config)
      -- ========================================================================
      dashboard.section.buttons.opts.hl = 'DashboardCenter'
      dashboard.section.buttons.opts.hl_shortcut = 'DashboardShortCut'
      dashboard.section.buttons.val = {
        dashboard.button(
          'r',
          '  Recently used files',
          '<Cmd>Telescope oldfiles<CR>'
        ),
        dashboard.button(
          'f',
          '  Find file',
          '<Cmd>Telescope find_files<CR>'
        ),
        dashboard.button(
          'g',
          '  Find text',
          '<Cmd>Telescope live_grep<CR>'
        ),
        dashboard.button(
          'p',
          '  Find project',
          '<Cmd>Telescope projects<CR>'
        ),
        dashboard.button('n', '  New file', '<Cmd>enew<CR>'),
        dashboard.button('c', '  Configuration', '<Cmd>e $MYVIMRC<CR>'),
        dashboard.button('l', '󰒲  Lazy', '<Cmd>Lazy<CR>'),
        dashboard.button('m', '  Mason', '<Cmd>Mason<CR>'),
        dashboard.button('h', '  Health check', '<Cmd>checkhealth<CR>'),
        dashboard.button('q', '  Quit Neovim', '<Cmd>confirm qa<CR>'),
      }

      -- ========================================================================
      -- Footer with Version Info and Inspiration
      -- ========================================================================
      dashboard.section.footer.opts.hl = 'DashboardFooter'
      local function footer()
        local version = vim.version()
        local nvim_version_info = 'Neovim v'
          .. version.major
          .. '.'
          .. version.minor
          .. '.'
          .. version.patch

        local lazy_stats = require('lazy').stats()
        local plugin_count = lazy_stats.loaded .. '/' .. lazy_stats.count .. ' plugins loaded'

        return {
          '',
          nvim_version_info .. ' • ' .. plugin_count,
          '',
          '✨ Welcome back, Thomas! Ready to create something amazing? ✨',
        }
      end
      dashboard.section.footer.val = footer()

      -- ========================================================================
      -- Padding and Layout
      -- ========================================================================
      dashboard.section.header.opts.margin = 5
      dashboard.section.buttons.opts.margin = 5
      dashboard.section.footer.opts.margin = 5

      -- Configure dashboard
      dashboard.config.opts.noautocmd = true

      -- Disable status line and tab line on alpha buffer
      vim.api.nvim_create_autocmd('User', {
        pattern = 'AlphaReady',
        callback = function()
          vim.opt.showtabline = 0
        end,
      })

      vim.api.nvim_create_autocmd('BufUnload', {
        buffer = 0,
        callback = function()
          vim.opt.showtabline = 2
        end,
      })

      alpha.setup(dashboard.opts)
    end,
  },

  -- ============================================================================
  -- Web Dev Icons for Beautiful File Icons
  -- ============================================================================
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
    config = function()
      require('nvim-web-devicons').setup({
        override = {
          zsh = {
            icon = '',
            color = '#428850',
            cterm_color = '65',
            name = 'Zsh'
          }
        },
        color_icons = true,
        default = true,
        strict = true,
        override_by_filename = {
          ['.gitignore'] = {
            icon = '',
            color = '#f1502f',
            name = 'Gitignore'
          }
        },
        override_by_extension = {
          ['log'] = {
            icon = '',
            color = '#81e043',
            name = 'Log'
          }
        },
      })
    end,
  },

  -- ============================================================================
  -- Indent Blankline for Beautiful Code Structure
  -- ============================================================================
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    main = 'ibl',
    opts = {
      indent = {
        char = '│',
        tab_char = '│',
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          'help',
          'alpha',
          'dashboard',
          'neo-tree',
          'Trouble',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'lazyterm',
        },
      },
    },
  },

  -- ============================================================================
  -- Colorizer for CSS/Color Highlighting
  -- ============================================================================
  {
    'NvChad/nvim-colorizer.lua',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('colorizer').setup({
        filetypes = { '*' },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = true,
          RRGGBBAA = false,
          AARRGGBB = true,
          rgb_fn = false,
          hsl_fn = false,
          css = false,
          css_fn = false,
          mode = 'background',
          tailwind = false,
          sass = { enable = false },
          virtualtext = '■',
        },
        buftypes = {},
      })
    end,
  },

  -- ============================================================================
  -- Bufferline - Beautiful Tab Enhancement
  -- ============================================================================
  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('bufferline').setup({
        options = {
          numbers = 'ordinal',
          close_command = 'Bdelete %d',
          right_mouse_command = 'Bdelete %d',
          left_mouse_command = 'buffer %d',
          middle_mouse_command = nil,
          max_name_length = 20,
          max_prefix_length = 15,
          tab_size = 25,
          diagnostics = 'nvim_lsp',
          diagnostics_update_in_insert = false,

          -- artistic offset for nvim-tree
          offsets = {
            {
              filetype = 'NvimTree',
              text = '𝐹𝑆', -- beautiful FS indicator
              padding = 1,
              text_align = 'left',
              highlight = 'StatusLineNC',
            },
          },

          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          separator_style = 'slant',
          enforce_regular_tabs = true,
          always_show_bufferline = false,

          -- Enhanced buffer filtering
          custom_filter = function(buf_number, _)
            -- Hide alpha dashboard from bufferline
            if vim.bo[buf_number].filetype == 'alpha' then
              return false
            end
            -- Hide Luapad.lua from bufferline
            if vim.fn.bufname(buf_number) == 'Luapad.lua' then
              return false
            end
            -- Hide empty/noname buffers
            if vim.fn.bufname(buf_number) == '' then
              return false
            end
            return true
          end,
        },

        highlights = {
          fill = {
            bg = {
              attribute = 'bg',
              highlight = 'StatusLineNC',
            },
          },
          buffer_visible = {
            fg = {
              attribute = 'fg',
              highlight = 'DiagnosticHint',
            },
          },
          close_button_visible = {
            fg = {
              attribute = 'fg',
              highlight = 'DiagnosticHint',
            },
          },
          separator = {
            fg = {
              attribute = 'bg',
              highlight = 'StatusLineNC',
            },
          },
          separator_selected = {
            fg = {
              attribute = 'bg',
              highlight = 'StatusLineNC',
            },
          },
          separator_visible = {
            fg = {
              attribute = 'bg',
              highlight = 'StatusLineNC',
            },
          },
          indicator_selected = {
            fg = {
              attribute = 'fg',
              highlight = 'Tag',
            },
          },
        },
      })

      -- ============================================================================
      -- Bufferline Keymaps
      -- ============================================================================
      local opts = { noremap = true, silent = true }

      -- Buffer navigation
      vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer', unpack(opts) })
      vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Previous buffer', unpack(opts) })

      -- Buffer movement
      vim.keymap.set('n', '<leader>bl', '<cmd>BufferLineMoveNext<CR>', { desc = 'Move buffer right', unpack(opts) })
      vim.keymap.set('n', '<leader>bh', '<cmd>BufferLineMovePrev<CR>', { desc = 'Move buffer left', unpack(opts) })

      -- Buffer management
      vim.keymap.set('n', '<leader>bc', '<cmd>BufferLinePickClose<CR>', { desc = 'Close buffer (pick)', unpack(opts) })
      vim.keymap.set('n', '<leader>bp', '<cmd>BufferLinePick<CR>', { desc = 'Pick buffer', unpack(opts) })

      -- Close buffers
      vim.keymap.set('n', '<leader>bse', '<cmd>BufferLineSortByExtension<CR>', { desc = 'Sort by extension', unpack(opts) })
      vim.keymap.set('n', '<leader>bsd', '<cmd>BufferLineSortByDirectory<CR>', { desc = 'Sort by directory', unpack(opts) })

      -- Direct buffer access (1-9)
      for i = 1, 9 do
        vim.keymap.set('n', '<leader>' .. i, '<cmd>BufferLineGoToBuffer ' .. i .. '<CR>', { desc = 'Go to buffer ' .. i, unpack(opts) })
      end
    end,
  },
}