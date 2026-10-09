-- =============================================================================
-- Restore classic Vim terminal colors and syntax palette
-- =============================================================================

-- 1. Disable 24-bit TrueColor so Neovim respects your terminal's ANSI palette
--    and your ~/.vimrc cterm highlight definitions (ctermfg, ctermbg).
vim.o.termguicolors = false

-- 2. Restore Vim's classic built-in default colorscheme
vim.cmd('colorscheme vim')

-- 3. Ensure background matches your .vimrc setting
vim.o.background = 'dark'

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

    -- nvim-lspconfig — LSP client configuration for language servers
    'https://github.com/neovim/nvim-lspconfig',

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
