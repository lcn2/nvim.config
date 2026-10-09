## Remarks about putting Neovim configuration under git control

### Should You Put `~/.local/share/nvim/site/pack/core/opt` Under Git Control?

**No, do not put the entire `opt` directory directly into a parent Git repository.**

Every directory inside `opt/` is already its own standalone Git clone (it contains its own `.git` directory). If you attempt to add `opt` directly to a Git repository, Git will treat them as nested repositories, create untracked submodules, or throw dirty-index warnings.

However, from a supply-chain and reproducible-build standpoint, there are two standard ways to manage this:

---

### What *Should* Be in Your Neovim Dotfiles Repository

Your dotfiles Git repository (typically managing `~/.config/nvim/`) should track:

1. **`~/.config/nvim/init.lua`**: Your configuration.
2. **`nvim-pack-lock.json`**: This file contains the exact commit SHA for every installed plugin.
* By default, `vim.pack` writes this file to `~/.local/share/nvim/site/pack/nvim-pack-lock.json`.
* **Best Practice:** Either symlink this lockfile into `~/.config/nvim/nvim-pack-lock.json` or track it so that your Git history shows whenever a plugin SHA advances. Whenever you run a diff on your dotfiles repo, any plugin update will show up as a clear, one-line commit hash change.


3. **`~/.config/nvim/after/` or `ftplugin/**` (if you create custom filetype scripts later).

---

### What Should *Not* Be Tracked in Git

Keep the rest of `~/.local/` and cache directories out of version control (add them to your global `.gitignore`):

* `~/.local/share/nvim/shada/`: This contains your command-line history, search history, jump marks, and register contents. Committing this risks leaking sensitive pasted text or confidential file paths.
* `~/.local/state/nvim/`: Contains undo trees, swap files, and log files.
* `~/.cache/nvim/`: Ephemeral language server caches and syntax parser binaries.

---

### If You Want Full Air-Gapped / Vendor Control Over Plugins

If you want the ultimate supply-chain guarantee (where your setup does not touch the network at all upon machine setup, and every line of third-party Lua code is committed and auditable in your own repository):

You can **vendor** your plugins:

1. Clone or copy the plugin directories directly into `~/.config/nvim/pack/vendor/start/` (removing their `.git` directories or tracking them as clean directories).
2. Because Vim and Neovim natively load anything under `pack/*/start/` on startup, they become static parts of your configuration repository.
3. However, tracking `nvim-pack-lock.json` with `vim.pack` achieves 99% of this benefit with far less repository bloat.
