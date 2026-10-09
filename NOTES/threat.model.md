## Remarks on a threat model for using Neovim

Here is a comprehensive security audit of your Neovim environment, addressing threat models, exposure vectors, supply chain pinning, and dependency minimization.

---

## 1. Threat Models & Neovim Execution Privileges

When you launch `nvim`, every loaded plugin runs within the context of your user account with **no sandboxing**:

* **Filesystem Access:** Any Lua or Vimscript file executed by Neovim has full read/write access to your user files: `~/.ssh/id_*`, `~/.gnupg`, `~/.aws/credentials`, shell histories (`~/.bash_history`), and private repositories.
* **Network & Shell Execution:** Lua in Neovim provides `vim.fn.system()`, `vim.uv.spawn()`, and direct socket/libuv bindings. A rogue plugin can spawn background subshells, execute `curl`/`nc`, or bind a reverse shell silently without triggering a prompt.
* **API Key Exfiltration:** Your `GEMINI_API_KEY` is loaded directly into process memory via `os.getenv()`. Any plugin in the Lua runtime can call `os.getenv("GEMINI_API_KEY")` and transmit it to an external server.

---

## 2. Local Filesystem & Network Exposure of Your Setup

Analyzing your configuration by operational behavior:

* **Pure Local Execution (Zero Network Activity):**
* `oil.nvim`, `nvim-treesitter`, `neoscroll`, `vim-tmux-navigator`
* These operate strictly on local buffers and files. Unless malicious code is introduced via an upstream commit, they generate zero outbound network traffic during editing.


* **Local Subprocess Spawners:**
* `fzf-lua`: Spawns `rg` (ripgrep) and `fd` to scan local directories.
* `lazygit.nvim`: Spawns the system `lazygit` binary in a terminal buffer.
* `nvim-dap`: Spawns debug adapters (`debugpy`, etc.) and binds local TCP ports (`127.0.0.1:<port>`) for communication with the debugger.
* `nvim-lspconfig`: Spawns local language server binaries (`clangd`, `ruff`, `rust-analyzer`, `ty`). These servers parse your code and may execute project-level build tools (e.g., `cargo check`).


* **Active Outbound Network Transmissions:**
* **`copilot.vim`:** Runs a local Node.js agent in the background that continuously streams your file content, cursor context, and neighboring tabs to GitHub/Microsoft servers (`api.github.com`).
* **`codecompanion.nvim` / `plenary.nvim`:** Whenever you invoke Gemini actions or chat, `plenary.curl` sends the buffer selection or chat prompt along with `GEMINI_API_KEY` to Google's API endpoints (`generativelanguage.googleapis.com`).

---

## 3. Pin-Locking Methods (Freezing Upstream Changes)

By default, Git-based plugin managers track the default branch (`main` or `master`). If an author's GitHub account is compromised, a subsequent `:lua vim.pack.update()` would immediately pull malicious code.

### Strategy A: Pinning Versions in `init.lua`

You already did this for `blink.cmp`. You can enforce semantic version ranges or specific Git tags across plugins that support them:

```lua
-- Pin to major/minor versions or releases
{ src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.x') },
{ src = 'https://github.com/stevearc/oil.nvim', version = vim.version.range('2.x') },

```

### Strategy B: Lockfile Discipline (`nvim-pack-lock.json`)

The file `~/.local/share/nvim/site/pack/nvim-pack-lock.json` records the exact Git commit SHA of every installed repository.

1. **Never automate updates:** Do not add `:lua vim.pack.update()` to autocommands or cron jobs.
2. **Version control your lockfile:** Track `nvim-pack-lock.json` in your dotfiles repository. If you ever migrate machines, Neovim will check out those exact commit hashes.
3. **Audit diffs before updating:** When you choose to update, verify what changed:
```bash
cd ~/.local/share/nvim/site/pack/core/opt/<plugin-name>
git fetch origin
git log --oneline HEAD..origin/main

```

---

## 4. Stripping Down: Safe Candidates for Removal

To reach a minimal, hardened setup without sacrificing your AI workflow, you can categorize your remaining plugins into **keep**, **optional**, and **redundant**:

### Group 1: Safely Removable (Zero Lost AI Functionality)

1. **`codediff.nvim`**: You already removed this. Classic Vimdiff (`:diffsplit`, `:diffthis`, `vimdiff file1 file2`) is built into Neovim's C core and requires no external Lua code.
2. **`lazygit.nvim`**: This is just a wrapper around the `lazygit` command. Instead of a plugin, run `lazygit` directly in a native Neovim terminal split (`:terminal lazygit`) or inside a `tmux` split pane.
3. **`oil.nvim`**: Built-in file explorers exist:
* Native Netrw (`:Explore`, `:edit .`) requires zero external code.
* Native `fzf-lua` can search and open any file in your project.


4. **`nvim-dap`**: If you do not actively set graphical breakpoints or step through Python execution inside Vim buffers, this entire debugging stack (and its DAP REPL keymaps) can be eliminated.
5. **`nvim-treesitter`**: Since you explicitly disabled Treesitter's syntax highlighter to preserve your classic `cterm` colors, Treesitter is only parsing syntax trees into memory without displaying them. You can safely remove it.

### Group 2: The Core Hardened Stack (What Remains)

If you strip out Group 1, your entire setup reduces to:

* **Navigation & LSP:**
* `christoomey/vim-tmux-navigator` (Tiny, audited Vimscript; indispensable for tmux).
* `ibhagwan/fzf-lua` (Fast fuzzy search; isolated tool).
* `neovim/nvim-lspconfig` (Official Neovim core repository; vetted).


* **AI & Completion:**
* `blink.cmp` (Fast, isolated completion; already pinned to `1.x`).
* `github/copilot.vim` (Official GitHub/Microsoft plugin).
* `plenary.nvim` + `olimorris/codecompanion.nvim` (Gemini Pro integration).

This drops your external plugin footprint from 14 down to 7 well-established, focused tools while preserving every aspect of your classic Vim feel, Copilot ghost-text, and Gemini Pro chat.
