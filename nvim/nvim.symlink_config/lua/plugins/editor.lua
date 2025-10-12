-- ============================================================================
-- Editor Enhancements
-- Statusline, file explorer, and editing improvements
-- ============================================================================

return {
  -- ============================================================================
  -- Lualine - Beautiful Statusline (Artistic & Functional)
  -- ============================================================================
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- ========================================================================
      -- Responsive Width Conditions (Smart Hiding on Small Windows)
      -- ========================================================================
      local min_width_small = function()
        return vim.fn.winwidth(0) > 60
      end

      local min_width_medium = function()
        return vim.fn.winwidth(0) > 80
      end

      local min_width_large = function()
        return vim.fn.winwidth(0) > 100
      end

      -- ========================================================================
      -- Git Branch Component (With Beautiful Icon)
      -- ========================================================================
      local branch = {
        'branch',
        icons_enabled = true,
        icon = ' ',
        padding = 1,
        cond = min_width_small,
      }

      -- ========================================================================
      -- Diagnostics Component (LSP Integration)
      -- ========================================================================
      local diagnostics = {
        'diagnostics',
        sources = { 'nvim_lsp', 'nvim_diagnostic' },
        sections = { 'error', 'warn', 'info', 'hint' },
        symbols = {
          error = '  ',
          hint = '  ',
          info = '  ',
          warn = '  ',
        },
        colored = true,
        update_in_insert = false,
        always_visible = false,
        padding = 2,
        cond = min_width_medium,
      }

      -- ========================================================================
      -- Git Diff Component (Shows File Changes)
      -- ========================================================================
      local diff = {
        'diff',
        colored = true,
        symbols = {
          added = '  ',
          modified = '  ',
          removed = '  ',
        },
        cond = min_width_large,
      }

      -- ========================================================================
      -- Filename Component (Enhanced with Path and Status)
      -- ========================================================================
      local filename = {
        'filename',
        file_status = true,
        path = 1,
        shorting_target = 20,
        padding = 2,
        symbols = {
          modified = '  ',
          readonly = '  ',
          unnamed = '[No Name]',
        },
        fmt = function(str)
          return '%=' .. str
        end,
      }

      -- ========================================================================
      -- Encoding Component (Hidden for UTF-8, Shows Others)
      -- ========================================================================
      local encoding = {
        'encoding',
        padding = 1,
        cond = min_width_large,
        fmt = function(enc_name)
          if enc_name == 'utf-8' then
            return ''
          end
          return enc_name
        end,
      }

      -- ========================================================================
      -- File Format Component (OS-Aware Icons)
      -- ========================================================================
      local fileformat = {
        'fileformat',
        symbols = {
          unix = ' ',
          dos = ' ',
          mac = ' ',
        },
        padding = 1,
        cond = min_width_small,
        fmt = function(ffmt_name)
          if ffmt_name == 'unix' or ffmt_name == ' ' then
            return ''
          end
          return ffmt_name
        end,
      }

      -- ========================================================================
      -- Filetype Component (Icon Only for Clean Look)
      -- ========================================================================
      local filetype = {
        'filetype',
        icons_enabled = true,
        icon_only = true,
        colored = false,
        padding = 2,
        cond = min_width_small,
      }

      -- ========================================================================
      -- Location Component (Beautiful Unicode Numbers)
      -- ========================================================================
      local use_number_chars = true
      local location = {
        'location',
        icons_enabled = true,
        icon = ' ',
        fmt = function(comp_str)
          if not use_number_chars then
            return comp_str
          end

          local number_chars = {
            ['1'] = '𝟏',
            ['2'] = '𝟐',
            ['3'] = '𝟑',
            ['4'] = '𝟒',
            ['5'] = '𝟓',
            ['6'] = '𝟔',
            ['7'] = '𝟕',
            ['8'] = '𝟖',
            ['9'] = '𝟗',
            ['0'] = '𝟬',
          }
          local location_status = string.format(
            '%3d ：%-3d',
            vim.fn.line('.'),
            vim.fn.col('.')
          )
          return string.gsub(location_status, '(%d)', function(n)
            return number_chars[n]
          end)
        end,
      }

      -- ========================================================================
      -- Mode Component (Single Character for Clean Look)
      -- ========================================================================
      local mode = {
        'mode',
        fmt = function(str)
          if not min_width_small() then
            return str:sub(1, 1)
          end
          return str:sub(1, 1)
        end,
      }

      -- ========================================================================
      -- Progress Component (Artistic Unicode Percentages)
      -- ========================================================================
      local use_progress_chars = true
      local progress_chars = {
        ' 𝟏𝟬％',
        ' 𝟐𝟬％',
        ' 𝟑𝟬％',
        ' 𝟒𝟬％',
        ' 𝟓𝟬％',
        ' 𝟔𝟬％',
        ' 𝟕𝟬％',
        ' 𝟖𝟬％',
        ' 𝟗𝟬％',
        '1𝟬𝟬％',
      }

      local progress = {
        'progress',
        icons_enabled = true,
        icon = '󰆌 ',
        cond = min_width_small,
        fmt = function(comp_str)
          if not use_progress_chars then
            return comp_str
          end

          local current_line = vim.fn.line('.')
          local total_lines = vim.fn.line('$')
          local line_ratio = current_line / total_lines

          local index = math.ceil(line_ratio * #progress_chars)
          return progress_chars[index]
        end,
      }

      -- ========================================================================
      -- Main Lualine Setup (Enhanced Configuration)
      -- ========================================================================
      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = {
            left = ' ',
            right = ' ',
          },
          section_separators = {
            left = '',
            right = '',
          },
          disabled_filetypes = {
            'alpha',
            'dashboard',
            'NvimTree',
            'Outline',
            'toggleterm',
            'lua.luapad',
            'man',
            'trouble',
            'lazy',
            'mason',
          },
          always_divide_middle = true,
        },
        sections = {
          lualine_a = { mode },
          lualine_b = { branch },
          lualine_c = { diff, filename },
          lualine_x = { diagnostics },
          lualine_y = { filetype, fileformat, encoding },
          lualine_z = { location, progress },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { filename },
          lualine_x = {},
          lualine_y = { filetype },
          lualine_z = {},
        },
        tabline = {},
        extensions = { 'nvim-tree', 'trouble', 'lazy', 'mason' },
      })
    end,
  },

  -- ============================================================================
  -- Nvim-Tree - File Explorer (Elegant & Functional)
  -- ============================================================================
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>e', '<cmd>NvimTreeToggle<cr>', desc = 'Toggle file explorer' },
      { '<leader>o', '<cmd>NvimTreeFocus<cr>', desc = 'Focus file explorer' },
    },
    config = function()
      -- Disable netrw at the very start of your init.lua (already done in init.lua)
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require('nvim-tree').setup({
        disable_netrw = false,
        hijack_netrw = false,
        hijack_cursor = true,
        update_cwd = true,

        -- Enhanced diagnostics integration
        diagnostics = {
          enable = true,
          show_on_dirs = true,
          debounce_delay = 50,
          icons = {
            error = ' ',
            hint = ' ',
            info = ' ',
            warning = ' ',
          },
        },

        -- Auto-update focused file
        update_focused_file = {
          enable = true,
          update_cwd = true,
          ignore_list = {},
        },

        -- View configuration
        view = {
          width = 50,
          side = 'left',
          preserve_window_proportions = false,
          number = false,
          relativenumber = false,
          signcolumn = 'yes',
        },

        -- Renderer configuration for beautiful icons
        renderer = {
          add_trailing = false,
          group_empty = false,
          highlight_git = true,
          full_name = false,
          highlight_opened_files = 'all',
          root_folder_modifier = ':~',
          indent_width = 2,
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = '└',
              edge = '│',
              item = '│',
              none = ' ',
            },
          },
          icons = {
            webdev_colors = true,
            git_placement = 'before',
            padding = ' ',
            symlink_arrow = ' ➛ ',
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = '',
              symlink = '',
              bookmark = '',
              folder = {
                arrow_closed = '',
                arrow_open = '',
                default = '',
                open = '',
                empty = '',
                empty_open = '',
                symlink = '',
                symlink_open = '',
              },
              git = {
                unstaged = '✗',
                staged = '✓',
                unmerged = '',
                renamed = '➜',
                untracked = '★',
                deleted = '',
                ignored = '◌',
              },
            },
          },
        },

        -- File filters
        filters = {
          dotfiles = false,
          custom = { '.git', '.DS_Store' },
          exclude = {},
        },

        -- Git integration
        git = {
          enable = true,
          ignore = true,
          show_on_dirs = true,
          timeout = 400,
        },

        -- Trash integration (macOS friendly)
        trash = {
          cmd = 'trash',
          require_confirm = true,
        },

        -- Actions configuration
        actions = {
          use_system_clipboard = true,
          change_dir = {
            enable = true,
            global = false,
            restrict_above_cwd = false,
          },
          expand_all = {
            max_folder_discovery = 300,
            exclude = {},
          },
          open_file = {
            quit_on_open = false,
            resize_window = true,
            window_picker = {
              enable = true,
              chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
              exclude = {
                filetype = { 'notify', 'packer', 'qf', 'diff', 'fugitive', 'fugitiveblame' },
                buftype = { 'nofile', 'terminal', 'help' },
              },
            },
          },
          remove_file = {
            close_window = true,
          },
        },

        -- UI configuration
        ui = {
          confirm = {
            remove = true,
            trash = true,
          },
        },

        -- Tab configuration
        tab = {
          sync = {
            open = false,
            close = false,
            ignore = {},
          },
        },

        -- Notification configuration
        notify = {
          threshold = vim.log.levels.INFO,
        },

        -- Log configuration
        log = {
          enable = false,
          truncate = false,
          types = {
            all = false,
            config = false,
            copy_paste = false,
            dev = false,
            diagnostics = false,
            git = false,
            profile = false,
            watcher = false,
          },
        },
      })

      -- Auto-close nvim-tree when it's the last window
      vim.api.nvim_create_autocmd('BufEnter', {
        nested = true,
        callback = function()
          if #vim.api.nvim_list_wins() == 1 and require('nvim-tree.utils').is_nvim_tree_buf() then
            vim.cmd('quit')
          end
        end,
      })
    end,
  },

  -- ============================================================================
  -- Telescope - Fuzzy Finder (Enhanced & Familiar)
  -- ============================================================================
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
      'nvim-telescope/telescope-file-browser.nvim',
      'ahmedkhalf/project.nvim',
    },
    cmd = 'Telescope',
    keys = {
      -- ========================================================================
      -- Custom Telescope Keymaps (Enhanced for Modern Workflow)
      -- ========================================================================

      -- Core file operations
      { '<leader>ff', '<cmd>Telescope find_files theme=ivy<cr>', desc = 'Find files' },
      { '<leader>fr', '<cmd>Telescope oldfiles theme=ivy<cr>', desc = 'Recent files' },
      { '<leader>fb', '<cmd>Telescope buffers theme=ivy<cr>', desc = 'Find buffers' },
      { '<leader>fe', '<cmd>Telescope file_browser theme=ivy<cr>', desc = 'File browser' },

      -- Text search
      { '<leader>fg', '<cmd>Telescope live_grep theme=ivy<cr>', desc = 'Find text' },
      { '<leader>fc', '<cmd>Telescope grep_string theme=ivy<cr>', desc = 'Find word under cursor' },
      { '<leader>/', '<cmd>Telescope current_buffer_fuzzy_find theme=ivy<cr>', desc = 'Fuzzy find in buffer' },

      -- Project management
      { '<leader>fp', '<cmd>Telescope projects theme=ivy<cr>', desc = 'Find projects' },
      { '<leader>fw', '<cmd>Telescope workspaces theme=ivy<cr>', desc = 'Find workspaces' },

      -- Development tools
      { '<leader>fd', '<cmd>Telescope diagnostics theme=ivy<cr>', desc = 'Find diagnostics' },
      { '<leader>fs', '<cmd>Telescope git_status theme=ivy<cr>', desc = 'Git status' },
      { '<leader>fh', '<cmd>Telescope help_tags theme=ivy<cr>', desc = 'Find help' },
      { '<leader>fk', '<cmd>Telescope keymaps theme=ivy<cr>', desc = 'Find keymaps' },
      { '<leader>fm', '<cmd>Telescope marks theme=ivy<cr>', desc = 'Find marks' },
      { '<leader>fj', '<cmd>Telescope jumplist theme=ivy<cr>', desc = 'Find jumps' },

      -- LSP operations
      { '<leader>flr', '<cmd>Telescope lsp_references theme=ivy<cr>', desc = 'LSP references' },
      { '<leader>fls', '<cmd>Telescope lsp_document_symbols theme=ivy<cr>', desc = 'Document symbols' },
      { '<leader>flw', '<cmd>Telescope lsp_workspace_symbols theme=ivy<cr>', desc = 'Workspace symbols' },
      { '<leader>fld', '<cmd>Telescope lsp_definitions theme=ivy<cr>', desc = 'LSP definitions' },
      { '<leader>fli', '<cmd>Telescope lsp_implementations theme=ivy<cr>', desc = 'LSP implementations' },

      -- Git operations
      { '<leader>fgc', '<cmd>Telescope git_commits theme=ivy<cr>', desc = 'Git commits' },
      { '<leader>fgb', '<cmd>Telescope git_branches theme=ivy<cr>', desc = 'Git branches' },
      { '<leader>fgs', '<cmd>Telescope git_stash theme=ivy<cr>', desc = 'Git stash' },

      -- Advanced searches
      { '<leader>fo', '<cmd>Telescope vim_options theme=ivy<cr>', desc = 'Vim options' },
      { '<leader>ft', '<cmd>Telescope filetypes theme=ivy<cr>', desc = 'File types' },
      { '<leader>fq', '<cmd>Telescope quickfix theme=ivy<cr>', desc = 'Quickfix list' },
      { '<leader>fl', '<cmd>Telescope loclist theme=ivy<cr>', desc = 'Location list' },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      telescope.setup({
        defaults = {
          -- ====================================================================
          -- Custom UI (Familiar and Beautiful)
          -- ====================================================================
          prompt_prefix = ' ',
          selection_caret = ' ',
          path_display = { 'smart' },

          -- File filtering
          file_ignore_patterns = {
            '%.git/',
            'node_modules/',
            '%.DS_Store',
            'target/',
            'build/',
            'dist/',
            '%.class',
            '%.o',
            '%.so',
            '%.swp',
            '%.zip',
          },

          -- Layout configuration
          layout_config = {
            horizontal = {
              prompt_position = 'bottom',
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },

          -- ====================================================================
          -- Enhanced Keymaps (Preserving Original + Modern Additions)
          -- ====================================================================
          mappings = {
            i = {
              -- History navigation (preserved from original)
              ['<C-n>'] = actions.cycle_history_next,
              ['<C-p>'] = actions.cycle_history_prev,

              -- Selection movement (preserved from original)
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<Down>'] = actions.move_selection_next,
              ['<Up>'] = actions.move_selection_previous,

              -- File selection (preserved from original)
              ['<CR>'] = actions.select_default,
              ['<C-x>'] = actions.select_horizontal,
              ['<C-v>'] = actions.select_vertical,
              ['<C-t>'] = actions.select_tab,

              -- Preview scrolling (preserved from original)
              ['<C-u>'] = actions.preview_scrolling_up,
              ['<C-d>'] = actions.preview_scrolling_down,
              ['<PageUp>'] = actions.results_scrolling_up,
              ['<PageDown>'] = actions.results_scrolling_down,

              -- Selection and quickfix (preserved from original)
              ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
              ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
              ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
              ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,

              -- Additional useful mappings
              ['<C-c>'] = actions.close,
              ['<C-l>'] = actions.complete_tag,
              ['<C-h>'] = actions.which_key,
            },

            n = {
              -- Basic navigation (preserved from original)
              ['<esc>'] = actions.close,
              ['<CR>'] = actions.select_default,
              ['<C-x>'] = actions.select_horizontal,
              ['<C-v>'] = actions.select_vertical,
              ['<C-t>'] = actions.select_tab,

              -- Selection toggles (preserved from original)
              ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
              ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
              ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
              ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,

              -- Vim-style movement (preserved from original)
              ['j'] = actions.move_selection_next,
              ['k'] = actions.move_selection_previous,
              ['H'] = actions.move_to_top,
              ['M'] = actions.move_to_middle,
              ['L'] = actions.move_to_bottom,
              ['gg'] = actions.move_to_top,
              ['G'] = actions.move_to_bottom,

              -- Arrow keys (preserved from original)
              ['<Down>'] = actions.move_selection_next,
              ['<Up>'] = actions.move_selection_previous,

              -- Scrolling (preserved from original)
              ['<C-u>'] = actions.preview_scrolling_up,
              ['<C-d>'] = actions.preview_scrolling_down,
              ['<PageUp>'] = actions.results_scrolling_up,
              ['<PageDown>'] = actions.results_scrolling_down,

              -- Help
              ['?'] = actions.which_key,
            },
          },
        },

        -- ======================================================================
        -- Picker-Specific Configurations
        -- ======================================================================
        pickers = {
          find_files = {
            hidden = true,
            find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
          },
          live_grep = {
            additional_args = function()
              return { '--hidden', '--glob', '!**/.git/*' }
            end,
          },
          buffers = {
            show_all_buffers = true,
            sort_lastused = true,
            mappings = {
              i = {
                ['<c-d>'] = actions.delete_buffer,
              },
              n = {
                ['dd'] = actions.delete_buffer,
              },
            },
          },
          git_files = {
            hidden = true,
            show_untracked = true,
          },
          oldfiles = {
            only_cwd = false,
          },
        },

        -- ======================================================================
        -- Extensions Configuration (Custom Setup)
        -- ======================================================================
        extensions = {
          -- File browser (preserved from original)
          file_browser = {
            theme = 'ivy',
            hijack_netrw = false,
            mappings = {
              ['i'] = {
                -- Insert mode mappings for file browser
              },
              ['n'] = {
                -- Normal mode mappings for file browser
              },
            },
          },

          -- FZF native (enhanced performance)
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },

          -- Projects extension
          projects = {
            theme = 'ivy',
          },
        },
      })

      -- ========================================================================
      -- Load Extensions (Enhanced from Original)
      -- ========================================================================
      local load_extensions = function()
        pcall(telescope.load_extension, 'fzf')
        pcall(telescope.load_extension, 'file_browser')
        pcall(telescope.load_extension, 'projects')
        return true
      end

      load_extensions()
    end,
  },

  -- ============================================================================
  -- Auto Pairs - Smart Bracket Management
  -- ============================================================================
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'hrsh7th/nvim-cmp' },
    config = function()
      local autopairs = require('nvim-autopairs')

      autopairs.setup({
        check_ts = true,
        disable_filetype = { 'TelescopePrompt', 'alpha' },

        -- custom fast wrap feature
        fast_wrap = {
          map = '<C-j>', -- configured key for fast wrap
          chars = { '{', '[', '(', '"', "'" },
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
          offset = 0,
          end_key = '$',
          keys = 'qwertzuiopyxcvbnmasdfghjkl', -- QWERTZ layout support
          check_comma = true,
          highlight = 'PmenuSel',
          highlight_grey = 'LineNr',
        },

        -- Enhanced treesitter configuration
        ts_config = {
          lua = { 'string', 'source' },
          javascript = { 'string', 'template_string' },
          typescript = { 'string', 'template_string' },
          java = true,
          python = { 'string' },
          rust = { 'string' },
          go = { 'string' },
        },

        -- Disable for certain nodes
        disable_in_macro = false,
        disable_in_visualblock = false,
        disable_in_replace_mode = true,
        ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
        enable_moveright = true,
        enable_afterquote = true,
        enable_check_bracket_line = true,
        enable_bracket_in_quote = true,
        enable_abbr = false,
        break_undo = true,
        check_line_pair = true,
        map_bs = true,
        map_c_h = false,
        map_c_w = false,
      })

      -- Integration with nvim-cmp for better completion experience
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done({
          map_char = {
            tex = '', -- Disable for tex files
          },
        })
      )

      -- Custom rules for enhanced functionality
      local Rule = require('nvim-autopairs.rule')

      -- Add spaces inside brackets/braces when appropriate
      autopairs.add_rules({
        Rule(' ', ' ')
          :with_pair(function(opts)
            local pair = opts.line:sub(opts.col - 1, opts.col)
            return vim.tbl_contains({ '()', '[]', '{}' }, pair)
          end),
        Rule('( ', ' )')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%)') ~= nil
          end)
          :use_key(')'),
        Rule('{ ', ' }')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%}') ~= nil
          end)
          :use_key('}'),
        Rule('[ ', ' ]')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%]') ~= nil
          end)
          :use_key(']'),
      })
    end,
  },

  -- ============================================================================
  -- Surround - Modern Lua Replacement for tpope/vim-surround
  -- ============================================================================
  {
    'kylechui/nvim-surround',
    version = '*',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup({
        keymaps = {
          insert = '<C-g>s',
          insert_line = '<C-g>S',
          normal = 'ys',
          normal_cur = 'yss',
          normal_line = 'yS',
          normal_cur_line = 'ySS',
          visual = 'S',
          visual_line = 'gS',
          delete = 'ds',
          change = 'cs',
          change_line = 'cS',
        },

        -- Enhanced surrounds with modern features
        surrounds = {
          -- Parentheses
          ['('] = { add = { '( ', ' )' }, find = '%b()', delete = '^(. ?)().-( ?.)()$' },
          [')'] = { add = { '(', ')' }, find = '%b()', delete = '^(.)().-(.)()$' },

          -- Brackets
          ['['] = { add = { '[ ', ' ]' }, find = '%b[]', delete = '^(. ?)().-( ?.)()$' },
          [']'] = { add = { '[', ']' }, find = '%b[]', delete = '^(.)().-(.)()$' },

          -- Braces
          ['{'] = { add = { '{ ', ' }' }, find = '%b{}', delete = '^(. ?)().-( ?.)()$' },
          ['}'] = { add = { '{', '}' }, find = '%b{}', delete = '^(.)().-(.)()$' },

          -- Quotes
          ["'"] = { add = { "'", "'" }, find = "'.-'", delete = "^(.)().-(.)()$" },
          ['"'] = { add = { '"', '"' }, find = '".-"', delete = '^(.)().-(.)()$' },

          -- Backticks for code
          ['`'] = { add = { '`', '`' }, find = '`.-`', delete = '^(.)().-(.)()$' },

          -- Custom surrounds for programming
          ['f'] = {
            add = function()
              local result = require('nvim-surround.config').get_input('Enter the function name: ')
              if result then
                return { { result .. '(' }, { ')' } }
              end
            end,
            find = '[%w_]+%b()',
            delete = '^([%w_]+%()().-(%))()$',
          },

          -- Tags (HTML/XML)
          ['t'] = {
            add = function()
              local result = require('nvim-surround.config').get_input('Enter the tag name: ')
              if result then
                return { { '<' .. result .. '>' }, { '</' .. result .. '>' } }
              end
            end,
            find = '<[^>]*>.-</%w*>',
            delete = '^(<[^>]*>)().-(</%w*>)()$',
            change = {
              target = '^<([^>]*)().-(</?)([^>]*)>()$',
              replacement = function()
                local result = require('nvim-surround.config').get_input('Enter the tag name: ')
                if result then
                  return { { result }, { result } }
                end
              end,
            },
          },
        },

        -- Aliases for convenience
        aliases = {
          ['a'] = '>',
          ['b'] = ')',
          ['B'] = '}',
          ['r'] = ']',
          ['q'] = { '"', "'", '`' },
          ['s'] = { '}', ')', ']', '>', '"', "'", '`' },
        },

        -- Highlight duration
        highlight = {
          duration = 200,
        },

        -- Move cursor to end after adding
        move_cursor = 'begin',

        -- Indent on new lines
        indent_lines = function(start, stop)
          local b = vim.bo
          return b.autoindent or b.smartindent or b.cindent
        end,
      })
    end,
  },

  -- ============================================================================
  -- Better Buffer Deletion - Fork of vim-bbye
  -- ============================================================================
  {
    'Buckmeister/vim-bbye',
    cmd = { 'Bdelete', 'Bwipeout' },
    keys = {
      { '<leader>x', '<cmd>Bdelete<CR>', desc = 'Close buffer (smart)' },
    },
  },

  -- ============================================================================
  -- Project Management (For Telescope Projects Integration)
  -- ============================================================================
  {
    'ahmedkhalf/project.nvim',
    config = function()
      require('project_nvim').setup({
        detection_methods = { 'lsp', 'pattern' },
        patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json', 'Cargo.toml' },
        ignore_lsp = {},
        exclude_dirs = {},
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = 'global',
        datapath = vim.fn.stdpath('data'),
      })
    end,
  },
}