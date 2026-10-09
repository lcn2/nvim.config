## How to delete an installed Neovim plugin

To delete a plugin using `vim.pack`, follow this exact sequence:

1. **Edit `init.lua` first:**
* Delete or comment out `'[https://github.com/esmuellert/codediff.nvim](https://github.com/esmuellert/codediff.nvim)',` inside `vim.pack.add({ ... })`.
* Delete the entire `-- Setup for: codediff.nvim` block (the `require("codediff").setup({})` call and its associated keymaps).


2. **Save and quit Neovim completely:**
```vim
:wq

```

3. **Re-open Neovim** (now `codediff.nvim` is inactive and not loaded into memory).
4. **Run the delete command:**
```vim
:lua vim.pack.del({'codediff.nvim'})

```

*Alternative manual removal:* If you ever want to bypass Neovim's check, you can always delete the directory directly from your shell:
```bash
rm -rf ~/.local/share/nvim/site/pack/core/opt/codediff.nvim

```
