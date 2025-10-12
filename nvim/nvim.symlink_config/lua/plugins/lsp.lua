-- ============================================================================
-- Language Server Protocol (LSP) Configuration
-- Modern language support with completion, diagnostics, and more
-- Respects system-wide language server installations
-- ============================================================================

return {
  -- ============================================================================
  -- LSP Configuration Manager
  -- ============================================================================
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- ============================================================================
      -- LSP UI Configuration
      -- ============================================================================

      -- Configure diagnostic display
      vim.diagnostic.config({
        virtual_text = {
          prefix = '●',
          severity = nil,
          source = 'if_many',
          format = nil,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          focusable = false,
          style = 'minimal',
          border = 'rounded',
          source = 'always',
          header = '',
          prefix = '',
        },
      })

      -- Configure LSP floating windows
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or 'rounded'
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      -- ============================================================================
      -- System-Wide Language Server Configurations
      -- ============================================================================

      -- Java (JDT.LS) - Using system installation
      vim.lsp.config('jdtls', {
        capabilities = capabilities,
        cmd = {
          'java',
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ALL',
          '-Xms1g',
          '-Xmx2G',
          '--add-modules=ALL-SYSTEM',
          '--add-opens', 'java.base/java.util=ALL-UNNAMED',
          '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
          '-jar', '/usr/local/share/jdt.ls/plugins/org.eclipse.equinox.launcher_1.6.500.v20230717-2134.jar',
          '-configuration', '/usr/local/share/jdt.ls/config_mac',
          '-data', vim.fn.expand('~/.local/share/jdt.ls/workspaces/') .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
        },
        root_dir = function(bufnr, on_dir)
          on_dir(vim.fs.root(bufnr, { 'pom.xml', 'gradle.build', '.git' }) or vim.uv.cwd())
        end,
        settings = {
          java = {
            eclipse = {
              downloadSources = true,
            },
            configuration = {
              updateBuildConfiguration = "interactive",
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
            format = {
              enabled = true,
            },
          },
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.mockito.Mockito.*"
            },
            importOrder = {
              "java",
              "javax",
              "com",
              "org"
            },
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
            },
            useBlocks = true,
          },
        },
      })

      -- Rust (rust-analyzer) - Using system installation
      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
        cmd = { '/usr/local/bin/rust-analyzer' },
        settings = {
          ['rust-analyzer'] = {
            imports = {
              granularity = {
                group = 'module',
              },
              prefix = 'self',
            },
            cargo = {
              buildScripts = {
                enable = true,
              },
            },
            procMacro = {
              enable = true,
            },
            checkOnSave = {
              command = 'clippy',
            },
          },
        },
      })

      -- Lua (lua-language-server) - Using system installation
      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        cmd = { '/usr/local/bin/lua-language-server' },
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            diagnostics = {
              globals = { 'vim' },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
            format = {
              enable = true,
              defaultConfig = {
                indent_style = 'space',
                indent_size = '2',
              },
            },
          },
        },
      })

      -- Python - Using system installations (both available)
      -- Prioritize pylsp as it's more feature-complete
      if vim.fn.executable('/usr/local/bin/pylsp') == 1 then
        vim.lsp.config('pylsp', {
          capabilities = capabilities,
          cmd = { '/usr/local/bin/pylsp' },
          settings = {
            pylsp = {
              plugins = {
                pycodestyle = { enabled = false },
                mccabe = { enabled = false },
                pyflakes = { enabled = false },
                flake8 = { enabled = true },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                black = { enabled = true },
                pylint = { enabled = false },
                rope_completion = { enabled = true },
                rope_autoimport = { enabled = true },
              },
            },
          },
        })
      elseif vim.fn.executable('/usr/local/bin/jedi-language-server') == 1 then
        vim.lsp.config('jedi_language_server', {
          capabilities = capabilities,
          cmd = { '/usr/local/bin/jedi-language-server' },
        })
      end

      -- Haskell (HLS) - Using GHCup installation
      local hls_wrapper = vim.fn.expand('~/.ghcup/bin/haskell-language-server-wrapper')
      if vim.fn.executable(hls_wrapper) == 1 then
        vim.lsp.config('hls', {
          capabilities = capabilities,
          cmd = { hls_wrapper, '--lsp' },
          filetypes = { 'haskell', 'lhaskell' },
          root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, { '*.cabal', 'stack.yaml', 'cabal.project', 'package.yaml', 'hie.yaml', '.git' }))
          end,
          settings = {
            haskell = {
              cabalFormattingProvider = 'cabalfmt',
              formattingProvider = 'ormolu',
              checkParents = 'CheckOnSave',
              checkProject = true,
              maxProblemCount = 100,
              diagnosticsOnChange = true,
              liquidOn = false,
              completionSnippetsOn = true,
              maxCompletions = 40,
              plugin = {
                stan = { globalOn = false },
                moduleName = { globalOn = true },
                pragmas = { globalOn = true },
                splice = { globalOn = true },
                importLens = {
                  globalOn = true,
                  codeActionsOn = true,
                  codeLensOn = true,
                },
                rename = { globalOn = true },
                retrie = { globalOn = true },
                hlint = {
                  globalOn = true,
                  diagnosticsOn = true,
                  codeActionsOn = true,
                },
                eval = { globalOn = true },
                class = { globalOn = true },
                tactics = { globalOn = true },
                fourmolu = { globalOn = true },
                gadt = { globalOn = true },
                qualifyImportedNames = { globalOn = true },
                refineImports = { globalOn = true },
                alternateNumberFormat = { globalOn = true },
                callHierarchy = { globalOn = true },
              },
            },
          },
        })
      end

      -- ============================================================================
      -- Enable All Configured Language Servers
      -- ============================================================================

      -- Enable system-wide language servers
      vim.lsp.enable('jdtls')
      vim.lsp.enable('rust_analyzer')
      vim.lsp.enable('lua_ls')

      -- Enable Python LSP (conditionally enabled above)
      if vim.fn.executable('/usr/local/bin/pylsp') == 1 then
        vim.lsp.enable('pylsp')
      elseif vim.fn.executable('/usr/local/bin/jedi-language-server') == 1 then
        vim.lsp.enable('jedi_language_server')
      end

      -- Enable Haskell LSP (conditionally enabled above)
      if vim.fn.executable(vim.fn.expand('~/.ghcup/bin/haskell-language-server-wrapper')) == 1 then
        vim.lsp.enable('hls')
      end

      -- Enable NPM-installed language servers (conditionally enabled above)
      if vim.fn.executable('typescript-language-server') == 1 then
        vim.lsp.enable('tsserver')
      end
      if vim.fn.executable('bash-language-server') == 1 then
        vim.lsp.enable('bashls')
      end
      if vim.fn.executable('yaml-language-server') == 1 then
        vim.lsp.enable('yamlls')
      end
      if vim.fn.executable('docker-langserver') == 1 then
        vim.lsp.enable('dockerls')
      end
      if vim.fn.executable('vim-language-server') == 1 then
        vim.lsp.enable('vimls')
      end
      if vim.fn.executable('pyright') == 1 and vim.fn.executable('/usr/local/bin/pylsp') ~= 1 then
        vim.lsp.enable('pyright')
      end
      if vim.fn.executable('vscode-html-language-server') == 1 then
        vim.lsp.enable('html')
      end
      if vim.fn.executable('vscode-css-language-server') == 1 then
        vim.lsp.enable('cssls')
      end
      if vim.fn.executable('vscode-json-language-server') == 1 then
        vim.lsp.enable('jsonls')
      end
      if vim.fn.executable('ngserver') == 1 then
        vim.lsp.enable('angularls')
      end

      -- Ruby (Solargraph) - Using system installation
      if vim.fn.executable('/usr/local/bin/solargraph') == 1 then
        vim.lsp.config('solargraph', {
          capabilities = capabilities,
          cmd = { '/usr/local/bin/solargraph', 'stdio' },
          filetypes = { 'ruby' },
          init_options = {
            formatting = true,
          },
          settings = {
            solargraph = {
              -- Core features
              autoformat = true,
              completion = true,
              diagnostic = true,
              folding = true,
              references = true,
              rename = true,
              symbols = true,

              -- Enhanced diagnostics and analysis
              useBundler = false,
              commandPath = "/usr/local/bin/solargraph",
              logLevel = "warn",
              reportIssues = "warning",

              -- Define configuration for better Ruby analysis
              definitions = true,
              hover = true,
              documentSymbol = true,
              workspaceSymbol = true,
            },
          },
        })
        vim.lsp.enable('solargraph')
      end

      -- ============================================================================
      -- NPM-Installed Language Servers
      -- ============================================================================

      -- TypeScript/JavaScript (typescript-language-server)
      if vim.fn.executable('typescript-language-server') == 1 then
        vim.lsp.config('tsserver', {
          capabilities = capabilities,
          cmd = { 'typescript-language-server', '--stdio' },
          filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
          init_options = {
            hostInfo = 'neovim',
          },
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = 'literal',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        })
        vim.lsp.enable('tsserver')
      end

      -- Bash (bash-language-server)
      if vim.fn.executable('bash-language-server') == 1 then
        vim.lsp.config('bashls', {
          capabilities = capabilities,
          cmd = { 'bash-language-server', 'start' },
          filetypes = { 'sh', 'bash', 'zsh' },
          settings = {
            bashIde = {
              globPattern = '*@(.sh|.inc|.bash|.command|.zsh)',
            },
          },
        })
        vim.lsp.enable('bashls')
      end

      -- YAML (yaml-language-server)
      if vim.fn.executable('yaml-language-server') == 1 then
        vim.lsp.config('yamlls', {
          capabilities = capabilities,
          cmd = { 'yaml-language-server', '--stdio' },
          filetypes = { 'yaml', 'yaml.docker-compose', 'yml' },
          settings = {
            yaml = {
              schemas = {
                ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
                ['https://json.schemastore.org/github-action.json'] = '/action.{yml,yaml}',
                ['https://json.schemastore.org/docker-compose.json'] = 'docker-compose*.{yml,yaml}',
                ['https://json.schemastore.org/kustomization.json'] = 'kustomization.{yml,yaml}',
                ['https://json.schemastore.org/chart.json'] = 'Chart.{yml,yaml}',
              },
              format = {
                enable = true,
              },
              validate = true,
              completion = true,
              hover = true,
            },
          },
        })
        vim.lsp.enable('yamlls')
      end

      -- Dockerfile (dockerfile-language-server-nodejs)
      if vim.fn.executable('docker-langserver') == 1 then
        vim.lsp.config('dockerls', {
          capabilities = capabilities,
          cmd = { 'docker-langserver', '--stdio' },
          filetypes = { 'dockerfile' },
          settings = {},
        })
        vim.lsp.enable('dockerls')
      end

      -- Vim script (vim-language-server)
      if vim.fn.executable('vim-language-server') == 1 then
        vim.lsp.config('vimls', {
          capabilities = capabilities,
          cmd = { 'vim-language-server', '--stdio' },
          filetypes = { 'vim' },
          init_options = {
            diagnostic = {
              enable = true,
            },
            indexes = {
              count = 3,
              gap = 100,
              projectRootPatterns = { 'runtime', 'nvim', '.git', 'autoload', 'plugin' },
              runtimepath = true,
            },
            iskeyword = '@,48-57,_,192-255,-#',
            runtimepath = '',
            suggest = {
              fromRuntimepath = true,
              fromVimruntime = true,
            },
            vimruntime = '',
          },
        })
        vim.lsp.enable('vimls')
      end

      -- Alternative Python language server (Pyright)
      -- Only enable if pylsp is not available (fallback option)
      if vim.fn.executable('pyright') == 1 and vim.fn.executable('/usr/local/bin/pylsp') ~= 1 then
        vim.lsp.config('pyright', {
          capabilities = capabilities,
          cmd = { 'pyright-langserver', '--stdio' },
          filetypes = { 'python' },
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = 'workspace',
                useLibraryCodeForTypes = true,
                typeCheckingMode = 'basic',
              },
            },
          },
        })
        vim.lsp.enable('pyright')
      end

      -- VSCode Language Servers (vscode-langservers-extracted)
      -- This package provides: html, css, json, eslint
      if vim.fn.executable('vscode-html-language-server') == 1 then
        vim.lsp.config('html', {
          capabilities = capabilities,
          cmd = { 'vscode-html-language-server', '--stdio' },
          filetypes = { 'html', 'templ' },
          init_options = {
            configurationSection = { 'html', 'css', 'javascript' },
            embeddedLanguages = {
              css = true,
              javascript = true,
            },
            provideFormatter = true,
          },
        })
        vim.lsp.enable('html')
      end

      if vim.fn.executable('vscode-css-language-server') == 1 then
        vim.lsp.config('cssls', {
          capabilities = capabilities,
          cmd = { 'vscode-css-language-server', '--stdio' },
          filetypes = { 'css', 'scss', 'less' },
          settings = {
            css = {
              validate = true,
            },
            less = {
              validate = true,
            },
            scss = {
              validate = true,
            },
          },
        })
        vim.lsp.enable('cssls')
      end

      if vim.fn.executable('vscode-json-language-server') == 1 then
        vim.lsp.config('jsonls', {
          capabilities = capabilities,
          cmd = { 'vscode-json-language-server', '--stdio' },
          filetypes = { 'json', 'jsonc' },
          init_options = {
            provideFormatter = true,
          },
          settings = {
            json = {
              schemas = {
                {
                  fileMatch = { 'package.json' },
                  url = 'https://json.schemastore.org/package.json',
                },
                {
                  fileMatch = { 'tsconfig*.json' },
                  url = 'https://json.schemastore.org/tsconfig.json',
                },
                {
                  fileMatch = { '.prettierrc', '.prettierrc.json', 'prettier.config.json' },
                  url = 'https://json.schemastore.org/prettierrc.json',
                },
                {
                  fileMatch = { '.eslintrc', '.eslintrc.json' },
                  url = 'https://json.schemastore.org/eslintrc.json',
                },
              },
            },
          },
        })
        vim.lsp.enable('jsonls')
      end

      -- Angular Language Server (for Angular projects)
      if vim.fn.executable('ngserver') == 1 then
        vim.lsp.config('angularls', {
          capabilities = capabilities,
          cmd = { 'ngserver', '--stdio', '--tsProbeLocations', 'node_modules', '--ngProbeLocations', 'node_modules' },
          filetypes = { 'typescript', 'html', 'typescriptreact', 'typescript.tsx' },
          root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, { 'angular.json', 'project.json' }))
          end,
          on_new_config = function(new_config, new_root_dir)
            new_config.cmd = {
              'ngserver',
              '--stdio',
              '--tsProbeLocations',
              new_root_dir .. '/node_modules',
              '--ngProbeLocations',
              new_root_dir .. '/node_modules',
            }
          end,
        })
        vim.lsp.enable('angularls')
      end

      -- ============================================================================
      -- Language Servers to be Installed via Mason
      -- ============================================================================

      -- Additional language servers will be installed via Mason as needed
      -- See the mason-lspconfig setup below for configuration

      -- ============================================================================
      -- Enhanced LSP Keymaps
      -- ============================================================================

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }

          -- Navigation
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)

          -- Documentation
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

          -- Code actions
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = ev.buf, desc = 'LSP: Rename' })
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'LSP: Code action' })
          vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format({ async = true })
          end, { buffer = ev.buf, desc = 'LSP: Format' })

          -- Workspace
          vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, { buffer = ev.buf, desc = 'LSP: Add workspace folder' })
          vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, { buffer = ev.buf, desc = 'LSP: Remove workspace folder' })
          vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, { buffer = ev.buf, desc = 'LSP: List workspace folders' })

          -- Diagnostics
          vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { buffer = ev.buf, desc = 'Show diagnostic' })
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { buffer = ev.buf, desc = 'Previous diagnostic' })
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { buffer = ev.buf, desc = 'Next diagnostic' })
          vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { buffer = ev.buf, desc = 'Diagnostics to location list' })

          -- Create a command :Format to format current buffer
          vim.api.nvim_buf_create_user_command(ev.buf, 'Format', function(_)
            vim.lsp.buf.format()
          end, { desc = 'Format current buffer with LSP' })
        end,
      })
    end,
  },

  -- ============================================================================
  -- LSP Server Management (Mason)
  -- Respects system-wide installations, only manages what's missing
  -- ============================================================================
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    build = ':MasonUpdate',
    config = function()
      require('mason').setup({
        ui = {
          border = 'rounded',
          width = 0.8,
          height = 0.8,
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗'
          }
        },
        pip = {
          upgrade_pip = true,
        },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 4,
      })
    end,
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'mason.nvim' },
    config = function()
      require('mason-lspconfig').setup({
        -- Only install language servers that are NOT already available system-wide
        ensure_installed = {
          -- Web development languages (if needed)
          -- 'html',
          -- 'cssls',
          -- 'tsserver',
          -- 'jsonls',

          -- Other languages you might want
          -- 'bashls',     -- Bash language server
          -- 'yamlls',     -- YAML language server
          -- 'marksman',   -- Markdown language server
        },

        -- Don't automatically install servers that we configure manually
        automatic_installation = false,

        handlers = {
          -- Default handler for servers installed by Mason
          function(server_name)
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- Skip servers we handle manually (system-wide and npm installations)
            local manual_servers = {
              'jdtls',          -- Java (system-wide JDT.LS)
              'rust_analyzer',  -- Rust (system-wide rust-analyzer)
              'lua_ls',         -- Lua (system-wide lua-language-server)
              'pylsp',          -- Python (system-wide pylsp)
              'jedi_language_server', -- Python (system-wide jedi)
              'hls',            -- Haskell (system-wide via GHCup)
              'solargraph',     -- Ruby (system-wide via brew)
              'tsserver',       -- TypeScript/JavaScript (npm)
              'bashls',         -- Bash (npm)
              'yamlls',         -- YAML (npm)
              'dockerls',       -- Dockerfile (npm)
              'vimls',          -- Vim script (npm)
              'pyright',        -- Python alternative (npm)
              'html',           -- HTML (npm - vscode-langservers-extracted)
              'cssls',          -- CSS (npm - vscode-langservers-extracted)
              'jsonls',         -- JSON (npm - vscode-langservers-extracted)
              'angularls',      -- Angular (npm)
            }

            for _, manual_server in ipairs(manual_servers) do
              if server_name == manual_server then
                return
              end
            end

            -- Configure Mason-installed servers with default settings
            vim.lsp.config(server_name, {
              capabilities = capabilities,
            })
            vim.lsp.enable(server_name)
          end,

        },
      })
    end,
  },

  -- ============================================================================
  -- Autocompletion Engine
  -- ============================================================================
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      -- Load VS Code style snippets
      require('luasnip.loaders.from_vscode').lazy_load()

      local check_backspace = function()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
      end

      local kind_icons = {
        Text = '',
        Method = 'm',
        Function = '',
        Constructor = '',
        Field = '',
        Variable = '',
        Class = '',
        Interface = '',
        Module = '',
        Property = '',
        Unit = '',
        Value = '',
        Enum = '',
        Keyword = '',
        Snippet = '',
        Color = '',
        File = '',
        Reference = '',
        Folder = '',
        EnumMember = '',
        Constant = '',
        Struct = '',
        Event = '',
        Operator = '',
        TypeParameter = '',
      }

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-1), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(1), { 'i', 'c' }),
          ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
          ['<C-y>'] = cmp.config.disable,
          ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif check_backspace() then
              fallback()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            vim_item.kind = string.format('%s', kind_icons[vim_item.kind])
            vim_item.menu = ({
              nvim_lsp = '[LSP]',
              luasnip = '[Snippet]',
              buffer = '[Buffer]',
              path = '[Path]',
            })[entry.source.name]
            return vim_item
          end,
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        experimental = {
          ghost_text = false,
          native_menu = false,
        },
      })

      -- Command line completion
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    end,
  },

  -- ============================================================================
  -- Syntax Highlighting and Language Parsing
  -- ============================================================================
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-context',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          -- Essential for Neovim itself
          'lua', 'vim', 'vimdoc', 'query',

          -- Languages based on system setup
          'java',        -- JDT.LS
          'rust',        -- rust-analyzer
          'python',      -- pylsp/jedi
          'ruby',        -- ruby_lsp (via Mason)

          -- Common languages for development
          'json', 'yaml', 'toml',
          'markdown', 'markdown_inline',
          'bash',        -- Used for both bash and zsh files (covers bash-language-server)
          'html', 'css', 'javascript', 'typescript', -- Full web development stack
          'scss',        -- SCSS support for advanced CSS
          'haskell',     -- Based on your Development directory
          'c', 'cpp',

          -- Configuration files
          'gitignore', 'gitcommit', 'git_config', 'git_rebase',
          'dockerfile', 'sql',
        },

        auto_install = true,

        -- Use bash parser for zsh files
        filetype_to_parsername = {
          zsh = "bash",
        },

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        indent = {
          enable = true,
          -- Disable for languages where it's problematic
          disable = { 'python' },
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            scope_incremental = false,
            node_decremental = '<bs>',
          },
        },

        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              -- Functions
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',

              -- Classes
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',

              -- Parameters
              ['ap'] = '@parameter.outer',
              ['ip'] = '@parameter.inner',

              -- Conditionals
              ['ai'] = '@conditional.outer',
              ['ii'] = '@conditional.inner',

              -- Loops
              ['al'] = '@loop.outer',
              ['il'] = '@loop.inner',

              -- Comments
              ['a/'] = '@comment.outer',
              ['i/'] = '@comment.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']f'] = '@function.outer',
              [']c'] = '@class.outer',
            },
            goto_next_end = {
              [']F'] = '@function.outer',
              [']C'] = '@class.outer',
            },
            goto_previous_start = {
              ['[f'] = '@function.outer',
              ['[c'] = '@class.outer',
            },
            goto_previous_end = {
              ['[F'] = '@function.outer',
              ['[C'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>sp'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>sP'] = '@parameter.inner',
            },
          },
        },
      })

      -- Configure treesitter context (shows function/class context at top)
      require('treesitter-context').setup({
        enable = true,
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
        trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      })
    end,
  },

  -- ============================================================================
  -- Diagnostics UI Improvements
  -- ============================================================================
  {
    'folke/trouble.nvim',
    cmd = { 'TroubleToggle', 'Trouble' },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('trouble').setup({
        icons = false,
        fold_open = 'v',
        fold_closed = '>',
        indent_lines = false,
        signs = {
          error = 'error',
          warning = 'warn',
          hint = 'hint',
          information = 'info'
        },
        use_diagnostic_signs = false
      })

      -- Keymaps
      vim.keymap.set('n', '<leader>dt', '<cmd>TroubleToggle<cr>', { desc = 'Toggle trouble' })
      vim.keymap.set('n', '<leader>dw', '<cmd>TroubleToggle workspace_diagnostics<cr>', { desc = 'Workspace diagnostics' })
      vim.keymap.set('n', '<leader>dd', '<cmd>TroubleToggle document_diagnostics<cr>', { desc = 'Document diagnostics' })
      vim.keymap.set('n', '<leader>dq', '<cmd>TroubleToggle quickfix<cr>', { desc = 'Quickfix list' })
      vim.keymap.set('n', '<leader>dl', '<cmd>TroubleToggle loclist<cr>', { desc = 'Location list' })
    end,
  },

  -- ============================================================================
  -- Code Formatting with conform.nvim
  -- ============================================================================
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format({ async = true, lsp_fallback = true })
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      formatters_by_ft = {
        -- Ruby formatting handled by Solargraph LSP
        lua = { 'stylua' },
        python = { 'black' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
      },

      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,  -- This will use Solargraph for Ruby formatting
      },
    },
  },

  -- ============================================================================
  -- Placeholder for Additional LSP Features
  -- ============================================================================
  -- These will be added as we discuss specific needs:
  -- - Debugging support (nvim-dap)
  -- - Code outline/symbols
  -- - Signature help enhancements
}