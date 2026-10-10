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
-- Restore last cursor position when reopening a file
-- =============================================================================

local restore_group = vim.api.nvim_create_augroup('restore_cursor_position', { clear = true })

-- Save position on buffer exit specifically for config files
vim.api.nvim_create_autocmd({ 'BufLeave', 'VimLeavePre' }, {
    group = restore_group,
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == '' then
            local pos = vim.api.nvim_win_get_cursor(0)
            -- Save directly into a global mark 'Z so it survives startup sourcing
            if pos[1] > 1 then
                pcall(vim.api.nvim_buf_set_mark, buf, 'Z', pos[1], pos[2], {})
            end
        end
    end,
})

-- Restore position after UI initialization is fully complete
vim.api.nvim_create_autocmd({ 'BufReadPost', 'UIEnter' }, {
    group = restore_group,
    callback = function(args)
        local buf = (args.buf and args.buf ~= 0) and args.buf or vim.api.nvim_get_current_buf()
        if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].cursor_restored then
            return
        end

        local exclude_filetypes = { 'gitcommit', 'gitrebase', 'help', 'qf' }
        if vim.tbl_contains(exclude_filetypes, vim.bo[buf].filetype) or vim.bo[buf].buftype ~= '' then
            return
        end

        -- Check standard '"' mark first; if line <= 1, check our saved 'Z mark
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        if mark[1] <= 1 then
            local z_mark = vim.api.nvim_buf_get_mark(buf, 'Z')
            if z_mark[1] > 1 then
                mark = z_mark
            end
        end

        local line_count = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 1 and mark[1] <= line_count then
            vim.b[buf].cursor_restored = true
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                    pcall(vim.api.nvim_win_set_cursor, 0, mark)
                    vim.cmd('normal! zvzz')
                end
            end)
        end
    end,
    desc = 'Jump to last known cursor position on file reopen',
})

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

-- Determine the proper Node.js binary path across macOS and RHEL
local node_candidates = {
    '/opt/homebrew/bin/node', -- macOS Apple Silicon
    '/usr/local/bin/node',    -- macOS Intel or local build
    '/usr/bin/node',          -- RHEL / Linux standard
}

for _, bin in ipairs(node_candidates) do
    if vim.fn.executable(bin) == 1 then
        vim.g.copilot_node_command = bin
        break
    end
end

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
