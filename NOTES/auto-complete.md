### 1. What is `<M-l>`?

In classic Vim terminology, **`M` stands for "Meta"**:

* On a PC/Linux keyboard, **`<M-l>` is `Alt + l**`.
* On a Mac keyboard, **`<M-l>` is `Option + l**`.

**Common Terminal Gotcha (especially macOS Terminal or iTerm2):**
By default, macOS terminals intercept the `Option` key to produce special Unicode characters (e.g., `Option + l` might type `¬` instead of sending an escape sequence).

* In **Terminal.app**: Go to *Settings → Profiles → Keyboard → check "Use Option as Meta key"*.
* In **iTerm2**: Go to *Preferences → Profiles → Keys → set "Left Option Key" to `Esc+*`.

If you prefer not to use the `Alt`/`Option` key at all, you can remap it to a classic Control sequence like `<C-j>` or `<C-f>`:

```lua
-- Accepts ghost text with Ctrl+J instead of Alt+L
vim.keymap.set('i', '<C-j>', 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false,
    desc = 'Accept Copilot suggestion'
})

```

---

### 3. Understanding and Controlling Autocompletions

In your setup, you have **two separate autocompletion engines** running simultaneously in insert mode:

| Completion Engine | What it looks like | What it is | How to accept / control |
| --- | --- | --- | --- |
| **Copilot Pro+ (`copilot.vim`)** | Gray / dim "ghost text" trailing ahead of your cursor. | AI-generated code predictions. | • **Accept:** `<M-l>` (Alt-L or Option-L)<br>

<br>• **Cycle next suggestion:** `<M-]>`<br>

<br>• **Cycle previous suggestion:** `<M-[>`<br>

<br>• **Dismiss:** `<C-]>` |
| **LSP / Buffer (`blink.cmp`)** | A popup dropdown menu box showing keywords, symbols, or paths. | Language server semantic code completion. | • **Accept:** `<Tab>` or `<CR>` (Enter)<br>

<br>• **Navigate list:** `<Tab>` (down), `<S-Tab>` (up)<br>

<br>• **Dismiss popup:** `<C-e>` or continue typing |

Because we set `vim.g.copilot_no_tab_map = true`, `<Tab>` strictly operates on the `blink.cmp` popup menu, while `<M-l>` strictly accepts Copilot's ghost text.
