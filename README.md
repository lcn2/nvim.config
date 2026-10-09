# nvim.config

Neovim configuration that starts off with classic `vim(1)` and uses your `~/.vimrc` file.

## To Install

mkdir -p ~/.config
git clone https://github.com/lcn2/nvim.config.git nvim
nvim init.lua

## General remarks

We add useful settings for Neovim (v0.12 or later), that attempts to keep
the classic `vim(1)` look-and-feel.

We added some files to `NOTES/` as follows:

- NOTES/auto-complete.md

Remarks about Neovim auto-completion.

- NOTES/gemini.20261009.summary.md

A summary of a discussion with Gemini about Neovim.

- NOTES/HOWTO.delete.plugin.md

How to delete an installed Neovim plugin.

- NOTES/neovim.under.git.md

Remarks about putting Neovim configuration under git control.

- NOTES/old.20261007.init.lua

An old attempt at a `init.lua` that is **NOT** recommended,
but it put here for historical reference.

- NOTES/RHEL10.2.neovim.md

Remarks about running Neovim under Red Hat Enterprise Linux 10.2.

- NOTES/safe.20261009.init.lua

A copy of `init.lua` that was considered safe and effective.
This may differ from the current `init.lua`.  When in doubt,
use the current `init.lua` and treat this file as a historical reference.

- NOTES/supply-chain.risk.md

Remarks on the software supply chain risk of using Neovim plugins.

- NOTES/threat.model.md

Remarks on a threat model for using Neovim.
