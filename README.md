# nvim.config

Neovim configuration that starts off with classic `vim(1)` and uses your `~/.vimrc` file.

## To Install

```sh
mkdir -p ~/.config
git clone https://github.com/lcn2/nvim.config.git nvim
cd ~/.config/nvim
nvim init.lua
```

### say Y when neovim first asks you to install plugins

### optional: setup the included vim enviroment

```sh
if [[ -e ~/.vimrc ]]; then mv -f ~/.vimrc ~/.vimrc.old ; fi
cd ~/.config/nvim
cp -f NOTES/dot-vimrc ~/.vimrc
```

## General remarks

We add useful settings for Neovim (v0.12 or later), that attempts to keep
the classic `vim(1)` look-and-feel.

We added some files to `NOTES/` as follows:

- NOTES/dot-vimrc

This is a copy of our `~/.vimrc` that is included early on in our `init.lua`.
You will need to copy this file only if you want to re-create our full experience.

- NOTES/auto-complete.md

Remarks on neovim auto-completion.

- NOTES/gemini.20261009.summary.md

A summary of a discussion with Gemini about Neovim.

- NOTES/HOWTO.delete.plugin.md

How to delete an installed Neovim plugin.

- NOTES/neovim.under.git.md

Remarks about putting neovim configuration under git control.

- NOTES/old.20261007.init.lua

An old attempt at a `init.lua` that is **NOT** recommended,
but it put here for historical reference.

- NOTES/RHEL10.2.neovim.md

Remarks about running neovim under RHEL 10.2

- NOTES/safe.20261009.init.lua

A copy of `init.lua` that was considered safe and effective.
This may differ from the current `init.lua`.  When in doubt,
use the current `init.lua` and treat this file as a historical reference.

- NOTES/supply-chain.risk.md

Remarks on the software supply chain risk of using neovim plugins.

- NOTES/threat.model.md

Remarks on a threat model for using neovim.
