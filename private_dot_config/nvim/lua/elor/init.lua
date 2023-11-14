require("elor.packer")
require("elor.settings")
require("elor.keymap")
require("elor.yankhighlight")

-- shortcut: :PS -> :PackSync
vim.cmd [[command! PS PackerSync]]

-- Set lualine as statusline
-- See `:help lualine.txt`
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'onedark',
    component_separators = '|',
    section_separators = '',
  },
}

-- Enable Comment.nvim
require('Comment').setup()

-- Enable `lukas-reineke/indent-blankline.nvim`
-- See `:help indent_blankline.txt`
require('ibl').setup()

-- Gitsigns
-- See `:help gitsigns.txt`
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

-- SymbolsOutline
require("symbols-outline").setup()

-- Neotest
require('dapui').setup()
require('neotest').setup {
  adapters = {
    require('neotest-python'),
    require('neotest-rust'),
  }
}
-- enable neotest diagnostics?
vim.diagnostic.config({
  enable = true,
}, vim.api.nvim_create_namespace('neotest'))

-- Neotest hotkey: <leader>rt --> run.run(vim.fn.expand('%'))
RunTests = function()
  -- run test on file
  require("neotest").run.run(vim.fn.expand("%"))
end
local save_and_run_tests = function()
  vim.cmd [[w]]
  RunTests()
end
local display_test_output = function()
  require("neotest").output.open()
end
vim.keymap.set('n', '<leader>rt', save_and_run_tests)
vim.keymap.set('n', '<leader>ro', display_test_output)

-- run 'run_tests' whenever the current buffer is saved
-- TODO: use `vim.api.nvim_create_autocmd` instead
-- vim.cmd [[autocmd BufWritePost * lua RunTests()]]

-- rust-tools
local rt = require('rust-tools')
rt.setup {
  server = {
    inlay_hints = {
      auto = true,
      show_parameter_hints = true,
      show_type_hints = true,
    },
    hover_actions = {
      auto_focus = true,
    },
    tools = {
      autoSetHints = true,
      hover_with_actions = true,
      runnables = {
        use_telescope = true,
      },
    },
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          enable = true,
          overrideCommand = {
            "cargo",
            "clippy",
            "--all",
            "--",
            "-W",
            "clippy::all"
          },
        }
      }
    }
  }
}

rt.inlay_hints.enable()
rt.hover_actions.hover_actions()


-- DAP UI
require("neodev").setup({
  library = { plugins = { "nvim-dap-ui" }, types = true },
})

-- Debugging via DAP
local dap = require('dap')


local DEBUGGER_PATH = vim.fn.stdpath "data" .. "/site/pack/packer/opt/vscode-js-debug"

-- Python debugging
dap.adapters.python = function(cb, config)
  if config.request == 'attach' then
    ---@diagnostic disable-next-line: undefined-field
    local port = (config.connect or config).port
    ---@diagnostic disable-next-line: undefined-field
    local host = (config.connect or config).host or '127.0.0.1'
    cb({
      type = 'server',
      port = assert(port, '`connect.port` is required for a python `attach` configuration'),
      host = host,
      options = {
        source_filetype = 'python',
      },
    })
  else
    cb({
      type = 'executable',
      command = '/Users/elor/.pyenv/shims/python',
      args = { '-m', 'debugpy.adapter' },
      options = {
        source_filetype = 'python',
      },
    })
  end
end
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    -- Options for microsoft/debugpy, see docs there
    program = '${file}',
    pythonPath = function()
      local cwd = vim.fn.getcwd()
      local pyenv = vim.fn.glob(cwd .. '/.python-version')
      if pyenv ~= '' then
        return '/Users/elor/.pyenv/shims/python'
      end
      return '/opt/homebrew/bin/python3'
    end,
  },
}

-- Javascript debugging
require("dap-vscode-js").setup {
  node_path = "node",
  debugger_path = DEBUGGER_PATH,
  -- debugger_cmd = { "js-debug-adapter" },
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
}
dap.configurations.javascript = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    cwd = "${workspaceFolder}",
  },
}

-- Rust debugging via lldb-vscode
dap.adapters.lldb = {
  type = 'executable',
  command = '/opt/homebrew/opt/llvm/bin/lldb-vscode',
  name = "lldb",
}

local choose_cpp_program_and_args = function()
  -- choose args
  local program = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')

  if vim.fn.executable(program) == 0 then
    print(program .. ' is not executable; aborting')
    return
  end

  -- choose args
  local args_str = vim.fn.input('Arguments: ')
  local args = {}
  if not args_str ~= '' then
    args = vim.split(args_str, ' ')
  end

  return { program = program, args = args }
end

dap.configurations.cpp = {
  {
    name = 'Choose and Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      -- args is evaluated first, so this would be a duplicate.
      -- Just use the last cpp[] entry
      return dap.configurations.cpp[#dap.configurations.cpp].program
      -- local program_and_args = choose_cpp_program_and_args()
      -- return program_and_args.program
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = function()
      local program_and_args = choose_cpp_program_and_args()

      -- nil checks
      if program_and_args == nil then
        print('Error when choosing program and args; aborting')
        return
      end
      if program_and_args.program == nil then
        print('No program chosen; aborting')
        return
      end
      if program_and_args.args == nil then
        program_and_args.args = {}
      end

      table.insert(dap.configurations.cpp, {
        name = 'Launch ' .. program_and_args.program .. ' ' .. table.concat(program_and_args.args, ' '),
        type = 'lldb',
        request = 'launch',
        program = program_and_args.program,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = program_and_args.args,
      })

      return program_and_args.args
    end,
  },
}

dap.configurations.rust = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      print('Rust debugging: Compiling tests')
      local test_build_json = vim.fn.system('cargo test --quiet --message-format=json --no-run')

      print('Rust debugging: Finding test binary path')

      for line in test_build_json:gmatch("[^\r\n]+") do
        local decoded_line = vim.fn.json_decode(line)
        local path = decoded_line['executable']
        -- if path is a string, and an executable file exists at that paths
        if path ~= nil and vim.fn.filereadable(path) == 1 then
          print('Rust debugging: Executable found: ' .. path)
          return path
        end
      end

      print('Rust debugging: Could not find test binary path')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
  },
}

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = require('telescope.actions').delete_buffer,
      },
      n = {
        ['<C-d>'] = require('telescope.actions').delete_buffer,
      },
    },
    layout_config = {
      horizontal = {
        width = { padding = 2 },
        height = { padding = 2 },
      }
      -- other layout configuration here
    },
    file_ignore_patterns = { 'node_modules', 'target', 'dist', 'build', 'vendor', 'venv', '.git' },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', require('telescope.builtin').current_buffer_fuzzy_find,
  { desc = '[/] Fuzzily search in current buffer]' })

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch [D]iagnostics' })

vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch [K]eymaps' })

vim.keymap.set('n', '<C-P>', require('telescope.builtin').git_files, { desc = 'Search Git Files' })

-- [[ Debugging Hotkeys ]]
vim.keymap.set('n', '<F5>', require('dap').continue, { desc = 'Debugging: Continue, or Start' })
vim.keymap.set('n', '<F6>', function() require('dap').pause(1) end, { desc = 'Debugging: Pause thread 1' })
vim.keymap.set('n', '<F10>', require('dap').step_over, { desc = 'Debugging: Step Over' })
vim.keymap.set('n', '<F11>', require('dap').step_into, { desc = 'Debugging: Step Into' })
vim.keymap.set('n', '<F12>', require('dap').step_out, { desc = 'Debugging: Step Out' })
vim.keymap.set('n', '<F2>', require('dap').close, { desc = 'Debugging: Stop, and Close' })
vim.keymap.set('n', '<F8>', require('dap').toggle_breakpoint, { desc = 'Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dr', require('dap').repl.open, { desc = 'Open REPL' })
vim.keymap.set('n', '<leader>dl', require('dap').run_last, { desc = 'Run Last' })
-- open dapui
vim.keymap.set('n', '<leader>do', require('dapui').toggle, { desc = 'Open DapUI for Debugging' })

-- zoom in and out of tabs
vim.keymap.set("n", "<leader>zi", ":tab split<CR>", { desc = 'Zoom into current tab' })
vim.keymap.set("n", "<leader>zo", ":tab close<CR>", { desc = 'Zoom out of current tab' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'typescript', 'vim', 'nix' },

  highlight = { enable = true },
  indent = { enable = true, disable = { 'python' } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<c-backspace>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '[e', function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set('n', ']e', function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.cmd.CodeActionMenu, '[C]ode [A]ction Menu')
  nmap('<leader>cf', vim.lsp.buf.code_action, '[C]ode [F]ix')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  nmap('gf', vim.lsp.buf.format, '[G]oto [F]ormat')
  nmap('<leader>gf', vim.lsp.buf.format, '[G]oto [F]ormat')

  nmap('<leader>gu', function()
    vim.cmd('UndotreeToggle')
    vim.cmd('UndotreeFocus')
  end, '[G]oto [U]ndoTree')

  nmap('<leader>go', function()
    -- remember current buffer, in order to switch to it later
    local current_bufnr = vim.api.nvim_get_current_buf()
    vim.cmd('silent! SymbolsOutlineClose')
    vim.cmd('SymbolsOutlineOpen')
    -- switch back to remembered buffer
    vim.api.nvim_set_current_buf(current_bufnr)
  end, '[G]oto [O]utline')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- LazyGit shortcut
  nmap('<leader>lg', vim.cmd.LazyGit, 'Lazy[G]it Terminal')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local lsp_server_settings = {
  -- clangd = {},
  -- gopls = {},
  pyright = {},
  -- hls = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

local lsp_server_extra_capabilities = {
  clangd = {
    offsetEncoding = 'utf-8',
  }
}

-- Setup neovim lua configuration
require('neodev').setup()
--
-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(lsp_server_settings),
}

-- merges two dictionaries, e.g. for extending lsp capabilities
local mergeDicts = function(...)
  local result = {}
  for _, dict in ipairs { ... } do
    if dict == nil then
      -- pass
    else
      for k, v in pairs(dict) do
        result[k] = v
      end
    end
  end
  return result
end

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = mergeDicts(capabilities, lsp_server_extra_capabilities[server_name]),
      on_attach = on_attach,
      settings = lsp_server_settings[server_name],
    }
  end,
}

-- Turn on lsp status information
require('fidget').setup()

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete({}),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    --
    -- Tab and S-Tab are disabled: They clash with Copilot, and you can use the arrow keys instead
    --
    -- ['<Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    --   elseif luasnip.expand_or_jumpable() then
    --     luasnip.expand_or_jump()
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
    -- ['<S-Tab>'] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   elseif luasnip.jumpable(-1) then
    --     luasnip.jump(-1)
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}


require("trouble").setup({
  position = "right",
  auto_open = false,
  auto_close = false,
  auto_preview = true,
  auto_fold = false,
  height = 7,
})

require('illuminate').configure({
  -- providers = { 'treesitter' },
  delay = 10,
})

-- refactoring setup --
require('refactoring').setup({})
-- load refactoring Telescope extension
require("telescope").load_extension("refactoring")

-- Git plugin
require("telescope").load_extension("lazygit")

-- remap to open the Telescope refactoring menu in visual mode
vim.api.nvim_set_keymap(
  "v",
  "<leader>rr",
  "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
  { noremap = true }
)

-- copy to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set('n', '<leader>sc', "ggVG:Chat ", { desc = '[C]ode Chat (GPT)' })
vim.keymap.set('v', '<leader>sc', ":Chat ", { desc = '[C]ode Chat (GPT)' })

-- exit terminal mode using <Esc>
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- neotree
vim.keymap.set("n", "<leader>fe", ":Neotree<CR>")

-- stay centered
require('stay-centered')

-- playlist files are json
vim.cmd([[autocmd BufNewFile,BufRead *.playlist setfiletype json]])

-- require('my-first-neovim-package')
-- my_first_neovim_package()

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
