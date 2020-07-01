# Git Workflow

All code changes and additional features shall be initiated by Jira issues. This is the workflow:

- A new branch shall be created from the `dev` branch, with the name of the Jira issue key.
- Prefix all commits with issue number.
- `no-ff` Git commits will be created on this branch with adequate descriptions.
- The new branch will be merged back into `dev`, using the Jira issue key in the commit message.
- Goal complement and team agreement will be required for `master` pushes.
- `no-ff` version control on `master` merge with `dev`.
- Fast-forward `dev` with `master`.

Refer to the `dev` example of VIRA-134:

```
*   2020-06-17 76bac4c VIRA-134: ViraSetPriority ViraSetVersion ViraEditSummary ViraEditDescription (Travis Gall)
|\
| * 2020-06-17 d287266 VIRA-134: `ViraSetPriority` created (Travis Gall)
| * 2020-06-17 3974324 VIRA-134: `ViraSetVersion` created (Travis Gall)
| * 2020-06-17 ae3b1f4 VIRA-134: description and summary changed to `Update` (Travis Gall)
| * 2020-06-17 743774a VIRA-134: added summary and description edits (Travis Gall)
|/
*   2020-06-17 713dd4b VIRA-189: `Old Comments` wrapper (Travis Gall)
```

# Linters

## Python

Install `flake8`:

`pip install --user flake8`

The `flake8` configuration is found in python/setup.cfg.

## Vimscript

Install `vint` linter:

`pip install --user vim-vint`

# Auto-formatters

## Markdown

Prettier requires `npm` to be installed. Install `prettier`:

`npm install --global prettier`

## Python

Install `yapf` linter:

`pip install --user yapf`

The `yapf` configuration is found in `python/setup.cfg`.

## YAML

Prettier requires `npm` to be installed. Install `prettier`:

`npm install --global prettier`

# ALE (Vim Plugin) - Optional

ALE (Asynchronous Lint Engine) is a great Vim plugin for performing linting and auto-formatting of code. Follow the instructions to `install/configure` it: `https://github.com/dense-analysis/ale`.

ALE is also an LSP (Language Server Protocol) client. Read more about LSP and why it's awesome at `https://langserver.org`.

The following the recommended `.vimrc` configuration for ALE:

```
let g:ale_fixers = {
            \ '*': ['remove_trailing_lines', 'trim_whitespace'],
            \ 'markdown': ['prettier'],
            \ 'python': ['yapf'],
            \ 'yaml': ['prettier']
            \ }
let g:ale_linters = {
            \ 'python': ['flake8'],
            \ 'vim': ['vint']
            \ }
```
