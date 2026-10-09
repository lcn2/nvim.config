-- =============================================================================
-- Source your authoritative Vim configuration directly
-- =============================================================================

vim.cmd('source ~/.vimrc')

-- =============================================================================
-- Set <space> as leader (must happen before other plugins loaded)
-- =============================================================================

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- =============================================================================
-- Relative line numbers
-- =============================================================================

vim.o.relativenumber = true
vim.o.number = true

-- =============================================================================
-- Copy to clipboard shortcuts
-- =============================================================================

vim.keymap.set('n', '<leader>cp', function()
    local path = vim.fn.expand('%:p')
    vim.fn.setreg('+', path)
    vim.notify('Copied: ' .. path)
end, { desc = 'Copy absolute path' })

vim.keymap.set('n', '<leader>cr', function()
    local path = vim.fn.expand('%')
    vim.fn.setreg('+', path)
    vim.notify('Copied: ' .. path)
end, { desc = 'Copy relative path' })

-- =============================================================================
-- Plugins
--
-- Note: Update plugins via :lua vim.pack.update()
-- =============================================================================

vim.pack.add({
    -- ===============
    -- UI & Navigation
    -- ===============

    -- fzf-lua — fuzzy finder for files, buffers, and live grep
    'https://github.com/ibhagwan/fzf-lua', -- also $ brew install fzf

    -- nvim-treesitter — syntax highlighting and code parsing via Tree-sitter
    'https://github.com/nvim-treesitter/nvim-treesitter', -- also $ brew install tree-sitter-cli

    -- nvim-lspconfig — LSP client configuration for language servers
    'https://github.com/neovim/nvim-lspconfig',

    -- neoscroll - a smooth scrolling neovim plugin written in lua
    'https://github.com/karb94/neoscroll.nvim',

    -- nvim-dap - Debug Adapter Protocol client implementation for Neovim
    'https://github.com/mfussenegger/nvim-dap',

    -- oil.nvim - a file explorer for neovim
    'https://github.com/stevearc/oil.nvim',

    -- lazygit.nvim — lazygit inside Neovim
    'https://github.com/kdheepak/lazygit.nvim',

    -- codediff.nvim — side-by-side vscode like diff viewer
    'https://github.com/esmuellert/codediff.nvim',

    -- render-markdown.nvim - render markdown
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',

    -- vim-tmux-navigator - seamless tmux navigation
    'https://github.com/christoomey/vim-tmux-navigator',

    -- ================
    --  Completion & AI
    -- ================

    -- blink.cmp - fast Rust-based autocompletion engine
    {   -- pinning so rust binary dependency automatically downloads
        src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.x') },

    -- copilot.vim - official GitHub Copilot plugin for Neovim
    'https://github.com/github/copilot.vim',

    -- plenary.nvim - required dependency for codecompanion.nvim
    'https://github.com/nvim-lua/plenary.nvim',

    -- codecompanion.nvim - Gemini Pro integration
    'https://github.com/olimorris/codecompanion.nvim',
})

-- =============================================================================
-- Setup for: fzf-lua — fuzzy finder for files, buffers, and live grep
-- =============================================================================

local fzf = require('fzf-lua')
fzf.setup({
    fzf_colors = false,
    grep = {
        rg_opts = table.concat({
            "--column --line-number --no-heading --color=always --smart-case --max-columns=4096",
            "--colors 'path:none'",
            "--colors 'line:none'",
            "--colors 'column:none'",
            "--colors 'match:fg:225,255,229'",
            "-e",
        }, " "),
    },
    ui_select = {},
    keymap = {
        builtin = {
            ["<C-d>"] = 'preview-page-down', -- Better scrolling within the displays
            ["<C-u>"] = 'preview-page-up',
        },
    },
    winopts = {
        height  = 0.95, -- window height
        width   = 0.90, -- window width
        preview = {
            layout   = 'vertical',
            vertical = "down:30%",
        }
    },
    files = {
        formatter = 'path.filename_first',
    },
})

vim.keymap.set('n', '<leader><leader>', '<cmd>FzfLua files<cr>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>/', '<cmd>FzfLua live_grep<cr>', { desc = 'Find live grep' })
vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua resume<cr>', { desc = 'Resume last picker' })
vim.keymap.set('n', '<leader>,', '<cmd>FzfLua buffers<cr>', { desc = 'Buffers' })

vim.keymap.set('n', 'grr', fzf.lsp_references, { desc = 'References' })
vim.keymap.set('n', 'gri', fzf.lsp_implementations, { desc = 'Implementations' })
vim.keymap.set('n', 'gra', fzf.lsp_code_actions, { desc = 'Code actions' })
vim.keymap.set('n', 'gd', fzf.lsp_definitions, { desc = 'Go to definition' })

vim.keymap.set('n', '<leader>fc', '<cmd>FzfLua colorschemes<cr>', { desc = 'Pick colorscheme' })

-- =============================================================================
-- Setup for: nvim-treesitter — syntax highlighting and code parsing via Tree-sitter
-- =============================================================================

vim.cmd('syntax on')
vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- Safe setup check for nvim-treesitter parsers
pcall(function()
    require('nvim-treesitter').setup({
        ensure_installed = { "bash", "c", "lua", "vim", "vimdoc" },
    })
end)
opts = { ensure_installed = { "cpp" } }

-- =============================================================================
-- Setup for: nvim-lspconfig — LSP client configuration for language servers
-- =============================================================================

vim.lsp.config('rust_analyzer', {
    settings = {
        ['rust-analyzer'] = {
            check = {
                command = 'clippy',
            },
        },
    },
})
vim.lsp.enable({
    -- LSP for python: alternative for Microsoft pyright, and Microsoft pylance
    'ty', -- also $ uv tool install ty@latest

    -- Extremely fast Python linter and code formatter
    'ruff', -- also $ uv tool install ruff@latest

    -- Language Server for the Lua language
    'lua_ls', -- also $ brew install lua-language-server

    -- clang and friends :-)
    'clangd', -- also $ brew install llvm

    -- rust analyzer
    'rust_analyzer', -- also $ rustup component add rust-analyzer clippy rustfmt

    -- Bash Language Server for shell script diagnostics & completion
    'bashls',
})
vim.o.signcolumn = 'yes' -- make lsp warnings not widen the gutter

-- =============================================================================
-- Setup for: neoscroll - a smooth scrolling neovim plugin written in lua
-- =============================================================================

require('neoscroll').setup({
    hide_cursor = false,
    stop_eof = true,
    easing = 'quadratic',
    duration_multiplier = 0.30,
})

-- =============================================================================
-- Setup for: nvim-dap - Debug Adapter Protocol client implementation for Neovim
-- =============================================================================

local dap = require('dap')
dap.adapters.debugpy = function(cb, config) -- also $ uv tool install debugpy@latest
    if config.request == 'attach' then
        cb({
            type = 'server',
            port = config.connect.port,
            host = config.connect.host or '127.0.0.1',
        })
    else
        cb({
            type = 'executable',
            command = 'debugpy-adapter',
        })
    end
end
dap.configurations.python = { -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
    {
        type = 'debugpy',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        justMyCode = false,
        python = function()
            local root = vim.fs.root(0, '.venv')
            return { root and root .. '/.venv/bin/python' or 'python3' }
        end,
        cwd = function()
            return vim.fs.root(0, '.venv') or vim.fn.getcwd()
        end,
    },
    {
        type = 'debugpy',
        request = 'launch',
        name = 'Pytest current file',
        module = 'pytest',
        args = { '${file}', '-s' },
        justMyCode = false,
        python = function()
            local root = vim.fs.root(0, '.venv')
            return { root and root .. '/.venv/bin/python' or 'python3' }
        end,
        cwd = function()
            return vim.fs.root(0, '.venv') or vim.fn.getcwd()
        end,
    },
    {
        type = 'debugpy',
        request = 'launch',
        name = 'Pytest current file -k',
        module = 'pytest',
        args = function()
            local test_name = vim.fn.input('pytest -k: ')
            return { '${file}', '-s', '-k', test_name }
        end,
        justMyCode = false,
        python = function()
            local root = vim.fs.root(0, '.venv')
            return { root and root .. '/.venv/bin/python' or 'python3' }
        end,
        cwd = function()
            return vim.fs.root(0, '.venv') or vim.fn.getcwd()
        end,
    },
}
vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug toggle breakpoint' })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug continue' })
vim.keymap.set('n', '<leader>dq', dap.terminate, { desc = 'Debug terminate' })
vim.keymap.set('n', '<leader>dr', function()
    dap.repl.open({ height = 12 }, 'belowright split')
end, { desc = 'Debug open REPL' })
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'dap-repl',
    callback = function(ev)
        vim.keymap.set('i', '<C-p>', function() require('dap.repl').on_up() end,
            { buffer = ev.buf, desc = 'DAP REPL previous history' })
        vim.keymap.set('i', '<C-n>', function() require('dap.repl').on_down() end,
            { buffer = ev.buf, desc = 'DAP REPL next history' })
    end,
})
vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Debug run last' })
vim.keymap.set({ 'n', 'v' }, '<leader>dh', require('dap.ui.widgets').hover, { desc = 'Debug hover' })
vim.keymap.set('n', '<Down>', dap.step_over, { desc = 'Debug step over' })
vim.keymap.set('n', '<Right>', dap.step_into, { desc = 'Debug step into' })
vim.keymap.set('n', '<Left>', dap.step_out, { desc = 'Debug step out' })
vim.keymap.set('n', '<Up>', dap.restart_frame, { desc = 'Debug restart frame' })

-- =============================================================================
-- Setup for: oil.nvim - a file explorer for neovim
-- =============================================================================

require("oil").setup({
    keymaps = {
        ["<C-h>"] = "<C-w>h",
        ["<BS>"] = "<C-w>h", -- only if your terminal sends Ctrl-h as BS
        ["<C-l>"] = "<C-w>l",
        ["<C-j>"] = "<C-w>j",
        ["<C-k>"] = "<C-w>k",
    },
    columns = {
        { "mtime", highlight = "Comment" } },
    view_options = {
        show_hidden = true,
        sort = {
            { "type",  "asc" },
            { "mtime", "desc" },
        }
    },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- =============================================================================
-- Setup for: lazygit.nvim — lazygit inside Neovim
-- =============================================================================

local function git_line_history(start_line, end_line)
    start_line, end_line = math.min(start_line, end_line), math.max(start_line, end_line)
    local range = start_line .. ',' .. end_line .. ':' .. vim.fn.expand('%:t')
    local command = { 'git', '-C', vim.fn.expand('%:p:h'), '--no-pager', 'log', '-L', range }
    local output = vim.fn.systemlist(command)
    local command_text = vim.fn.join(vim.tbl_map(vim.fn.shellescape, command), ' ')

    vim.cmd('vnew')
    vim.bo.buftype = 'nofile'
    vim.bo.filetype = 'diff'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.list_extend({ command_text, '' }, output))
    vim.bo.modified = false
end
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'Lazygit' })
vim.keymap.set('n', '<leader>gb', function() vim.ui.open(vim.fn.systemlist('git remote get-url origin')[1]) end,
    { desc = 'Open git remote' })
vim.keymap.set('n', '<leader>gl', function()
    git_line_history(vim.fn.line('.'), vim.fn.line('.'))
end, { desc = 'Git line history' })
vim.keymap.set('v', '<leader>gl', function()
    git_line_history(vim.fn.line('v'), vim.fn.line('.'))
end, { desc = 'Git line history' })

-- =============================================================================
-- Setup for: codediff.nvim — side-by-side vscode like diff viewer
-- =============================================================================

require("codediff").setup({})
vim.keymap.set('n', '<leader>ru', '<cmd>CodeDiff<cr>', { desc = 'Code diff not staged' })
vim.keymap.set('n', '<leader>rm', '<cmd>CodeDiff main<cr>', { desc = 'Code diff main' })
vim.keymap.set('n', '<leader>rh', '<cmd>CodeDiff HEAD~1<cr>', { desc = 'Code diff previous commit' })
vim.api.nvim_create_autocmd("User", {
    pattern = "CodeDiffOpen",
    callback = function()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            vim.wo[win].cursorline = false
        end
    end,
})

-- =============================================================================
-- Setup for: render-markdown.nvim - render markdown
-- =============================================================================

require('render-markdown').setup({})

-- =============================================================================
-- Setup for: vim-tmux-navigator - seamless tmux navigation
-- =============================================================================

-- Enables <C-h>, <C-j>, <C-k>, <C-l> to move across Neovim splits and tmux panes.
-- Requires matching setup in ~/.tmux.conf: set -g @plugin 'christoomey/vim-tmux-navigator'
vim.g.tmux_navigator_no_mappings = 0

-- =============================================================================
-- Setup for: blink.cmp - fast Rust-based autocompletion engine
-- =============================================================================

require('blink.cmp').setup({
    keymap = {
        -- 'super-tab' lets TAB navigate & complete LSP popups in insert mode
        preset = 'super-tab',
    },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    signature = {
        enabled = true,
        window = { show_documentation = false },
    },
})

-- =============================================================================
-- Setup for: copilot.vim - official GitHub Copilot plugin for Neovim
-- =============================================================================

-- 1. Prevent Copilot from mapping <Tab> so blink.cmp's super-tab can function.
vim.g.copilot_no_tab_map = true

-- 2. Define Copilot accept keybinding in insert mode.
-- <M-l> (Alt-L / Option-L) accepts the inline ghost-text suggestion.
vim.keymap.set('i', '<M-l>', 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false,
    desc = 'Accept Copilot suggestion'
})

-- 3. Suggestion cycling and cancellation
vim.keymap.set('i', '<M-]>', '<Plug>(copilot-next)', { desc = 'Cycle to next Copilot suggestion' })
vim.keymap.set('i', '<M-[>', '<Plug>(copilot-previous)', { desc = 'Cycle to previous Copilot suggestion' })
vim.keymap.set('i', '<C-]>', '<Plug>(copilot-dismiss)', { desc = 'Dismiss Copilot suggestion' })

-- =============================================================================
-- Setup for: codecompanion.nvim - Gemini Pro integration
-- =============================================================================

-- Ensure dependencies are loaded into Lua's runtime path before executing setup
vim.cmd('packadd plenary.nvim')
vim.cmd('packadd codecompanion.nvim')

require("codecompanion").setup({
    adapters = {
        gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
                env = {
                    -- Reads GEMINI_API_KEY from your shell environment
                    api_key = "GEMINI_API_KEY",
                },
                schema = {
                    model = {
                        default = "gemini-1.5-pro-latest",
                    },
                },
            })
        end,
    },
    strategies = {
        chat = { adapter = "gemini" },
        inline = { adapter = "gemini" },
    },
})

-- Keymaps for Gemini actions and chat
-- <leader>ga opens the action palette (refactor, explain, fix)
-- <leader>gc opens an interactive AI chat buffer using Gemini Pro
vim.keymap.set({ "n", "v" }, "<leader>ga", "<cmd>CodeCompanionActions<cr>", { desc = "AI Actions (Gemini)" })
vim.keymap.set({ "n", "v" }, "<leader>gc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle AI Chat (Gemini)" })
