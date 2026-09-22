-- histroic vim preferences

-- set UTF-8 encoding
--
vim.o.encoding = "utf-8"

-- Enable autoindent
--
vim.o.ai = true

-- Declare the tags file as tags
--
-- CTRL-]                  Jump to definition of the keyword under cursor
-- :[count]ta[g] {name}    Jump to the count definition of {name}
-- :[count]ta[g]! {regexp} Jump to the count definition of {regexp} pattern
--
vim.o.tags = "tags"

-- Enable vim dark mode
--
vim.o.bg = "dark"

-- Ignore case in searches
--
-- NOTE: Can be overruled by using "\c" or "\C" in the pattern
--
vim.o.ignorecase = true

-- Case-insensitive searching unless we use capital letters
--
vim.o.smartcase = true

-- See: //stackoverflow.com/questions/1878974/redefine-tab-as-4-spaces
--
-- tabstop
--
--    The width of a hard tabstop measured in "spaces" -- effectively the
--    (maximum) width of an actual tab character.
--
vim.o.tabstop = 8

-- shiftwidth
--
--    The size of an "indent". It's also measured in spaces, so if your
--    code base indents with tab characters then you want shiftwidth to
--    equal the number of tab characters times tabstop. This is also used
--    by things like the =, > and < commands.
--
vim.o.shiftwidth = 4

-- softtabstop
--
--    Setting this to a non-zero value other than tabstop will make the
--    tab key (in insert mode) insert a combination of spaces (and possibly
--    tabs) to simulate tab stops at this width.
--
vim.o.softtabstop = 4

-- expandtab
--
--    Enabling this will make the tab key (in insert mode) insert spaces
--    instead of tab characters. This also affects the behavior of the
--    retab command.
--
vim.o.expandtab = false

-- smarttab
--
--    Enabling this will make the tab key (in insert mode) insert spaces
--    or tabs to go to the next indent of the next tabstop when the cursor
--    is at the beginning of a line (i.e. the only preceding characters
--    are whitespace).
--
vim.o.smarttab = true

-- format current paragraph
--
vim.keymap.set('n', '<Esc>g', '}!{fmt<CR>', { desc = 'apply the fmt command to the current paragraph' })

-- trim trailing whitespace
--
vim.keymap.set('n', '<Esc>l', ':%s/<Bslash>s<Bslash>+$//e<CR>', { desc = 'trim trailing whitespace' })

-- look for spaces before a tab
--
vim.keymap.set('n', '<Esc>s', '/  *<Tab><CR>', { desc = 'look for spaces before a tab' })

-- shellcheck file
--
-- See https://github.com/itspriddle/vim-shellcheck
--
-- To install:
--
-- mkdir -p ~/.vim/pack/shellcheck/start
-- cd ~/.vim/pack/shellcheck/start
-- git clone https://github.com/itspriddle/vim-shellcheck.git
-- vim -u NONE -c "helptags vim-shellcheck/doc" -c q
--
vim.keymap.set('n', '<Esc>c', ':compiler shellcheck<CR>::make! %<CR>:copen<CR>', { desc = 'run shellcheck on current file' })

-- Restore cursor position in Neovim when opening multiple files
-- Source - https://stackoverflow.com/a/79676790
-- Posted by SergioAraujo, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-09-21, License - CC BY-SA 4.0

local autocmd = vim.api.nvim_create_autocmd

-- @returns a "clear = true" augroup
local function augroup(name) return vim.api.nvim_create_augroup('sergio-lazyvim_' .. name, { clear = true }) end

autocmd('BufReadPost', {
    group = augroup('restore_position'),
    callback = function()
	local exclude = { 'gitcommit' }
	local buf = vim.api.nvim_get_current_buf()
	if vim.tbl_contains(exclude, vim.bo[buf].filetype) then return end

	local mark = vim.api.nvim_buf_get_mark(buf, '"')
	local line_count = vim.api.nvim_buf_line_count(buf)
	if mark[1] > 0 and mark[1] <= line_count then
		pcall(vim.api.nvim_win_set_cursor, 0, mark)
		vim.api.nvim_feedkeys('zvzz', 'n', true)
	end
    end,
    desc = 'Restore cursor position after reopening file',
})

-- See: https://youtu.be/BBCScVuP3xo?si=3Ozoi7dRw3ei5T0B
-- See: https://github.com/vossenwout/pookie-dotfiles/blob/main/neovim/.config/nvim/init.lua

-- Set <space> as leader (must happen before other plugins loaded)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Relative line numbers
vim.o.relativenumber = true
vim.o.number = true -- display absolute line number instead of 0

-- Copy to clipboard shortcuts
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

-- Raise dialog if you close unsaved buffer (prevent mistakes)
vim.o.confirm = true

-- Disable swap files to prevent annoying errors
vim.opt.swapfile = false

-- Snappy escape
vim.o.ttimeoutlen = 1

-- Vim diagnostics
vim.diagnostic.config({
    underline = false,       -- don't underline errors
    severity_sort = true,    -- show most severe error first
    update_in_insert = false, -- don't update while typing
    float = { source = 'if_many' }, -- nicer look for floats and show source if multiple sources (ex. ruff and ty)
    jump = { float = true }, -- automatically open the diagnostic float if you jump with [d ]d
})

-- Show diagnostics
vim.keymap.set('n', '<leader>D', vim.diagnostic.open_float, { desc = 'Show diagnostics' })

-- Easily move between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight yanks
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.highlight.on_yank({ timeout = 300 }) end,
})

-- Plugins
-- Pack guide: https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack#update
-- NOTE: Update via: :lua vim.pack.update()
-- NOTE: Delete via: :lua vim.pack.del({ 'fzf-lua', 'nvim-treesitter', 'nvim-lspconfig' })
vim.pack.add({
    -- fzf-lua — fuzzy finder for files, buffers, and live grep
    'https://github.com/ibhagwan/fzf-lua', -- also $ brew install fzf

    -- nvim-treesitter — syntax highlighting and code parsing via Tree-sitter
    'https://github.com/nvim-treesitter/nvim-treesitter', -- also $ brew install tree-sitter-cli

    -- nvim-lspconfig — LSP client configuration for language servers
    'https://github.com/neovim/nvim-lspconfig',

    -- neoscroll - a smooth scrolliing neovim plugin written in lua
    'https://github.com/karb94/neoscroll.nvim',

    -- nvim-dap - Debug Adapter Protocol client implementation for Neovim
    'https://github.com/mfussenegger/nvim-dap',

    -- 'https://github.com/stevearc/oil.nvim',

    -- lazygit.nvim — lazygit inside Neovim
    'https://github.com/kdheepak/lazygit.nvim',

    -- codediff.nvim — side-by-side vscode like diff viewer
    'https://github.com/esmuellert/codediff.nvim',

    -- 'https://github.com/goolord/alpha-nvim',

    -- render-markdown - render markdown
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',

    -- blink.cmp - fast Rust-based autocompletion engine
    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.x') }, -- pinning so rust binary dependency automatically downloads

    -- Colorschemes
    'https://github.com/rebelot/kanagawa.nvim',
})

-- Kanagawa Colorscheme
require('kanagawa').setup({
    colors = {
	theme = {
	    all = {
		ui = {
		    bg_gutter = "none"
		}
	    }
	}
    }
})
vim.cmd('colorscheme kanagawa-wave')

-- Markdown
require('render-markdown').setup({})

-- FzfLua Setup
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

-- Treesitter
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

-- LSP
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
    -- LSP for python: alternative for Microsoft pywrite, and Microsoft pylance
    'ty', -- also $ uv tool install ty@latest

    -- Extremely fast Python linter and code formatter
    'ruff', -- also $ uv tool install ruff@latest

    -- Language Server for the Lua language
    'lua_ls', -- also $ brew install lua-language-server

    -- clang and frirnds :-)
    'clangd', -- also $ brew install llvm

    -- rust analyzer
    'rust_analyzer', -- also $ rustup component add rust-analyzer clippy rustfmt

    -- Bash Language Server for shell script diagnostics & completion
    'bashls',
})
vim.o.signcolumn = 'yes' -- make lsp warnings not widen the gutter

-- maybe later?
-- Auto-format ("lint") on save (adapted from neovim docs :help auto-format)
-- vim.api.nvim_create_autocmd('LspAttach', {
-- 	group = vim.api.nvim_create_augroup('my.lsp', { clear = true }),
-- 	callback = function(ev)
-- 		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
-- 		if not client:supports_method('textDocument/willSaveWaitUntil')
-- 		    and client:supports_method('textDocument/formatting') then
-- 			vim.api.nvim_create_autocmd('BufWritePre', {
-- 				group = vim.api.nvim_create_augroup('my.lsp.fmt', { clear = false }),
-- 				buffer = ev.buf,
-- 				callback = function()
-- 					vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
-- 				end,
-- 			})
-- 		end
-- 	end,
-- })

-- Blink.cmp - fast Rust-based autocompletion engine with super-tab preset
require('blink.cmp').setup({
    keymap = {
	-- 'default' maps Tab to select next, Shift-Tab to select prev, Enter to accept
	-- You can also use 'enter' if you want Enter to accept without preselecting
	-- super-tab lets TAB complete the suggestion, even while in insert mode
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

-- Neoscroll
require('neoscroll').setup({
    hide_cursor = false,
    stop_eof = true,
    easing = 'quadratic',
    duration_multiplier = 0.30,
})

-- Dap (debugging)
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

-- Lazygit.nvim
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

-- Codediff (vscode like diffs :))
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
