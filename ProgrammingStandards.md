# Git Workflow

All code changes and additional features shall be initiated by Jira issues. This is the workflow:

- A new branch shall be created from the master branch, with the name of the Jira issue key
- Git commits will be created on this branch with adequate descriptions
- The new branch will be merged back into master, using the Jira issue key in the commit message

Refer to the example of VIRA-111:

```
*   2019-12-20 4cfbcaf (HEAD -> master, origin/master, origin/HEAD) VIRA-111: Added __default__ vira project template (Mike Boiko)
|\
| * 2019-12-20 c1a66c9 Updated instructions (Mike Boiko)
| * 2019-12-20 d06e4f1 Implemented logic for __default__ vira_project config (Mike Boiko)
|/
* 2019-12-11 31d472b Fixed another bug related to story point field in report (Mike Boiko)
```

# Linters

## Python

Install `flake8` and `pyls` linters:

`pip install --user flake8 python-language-server`

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

## YAML

Prettier requires `npm` to be installed. Install `prettier`:

`npm install --global prettier`

# ALE (Vim Plugin) - Optional

ALE (Asynchronous Lint Engine) is a great Vim plugin for performing linting and auto-formatting of code. Follow the instructions to install/configure it: https://github.com/dense-analysis/ale

ALE is also an LSP (Language Server Protocol) client. Read more about LSP and why it's awesome at https://langserver.org

The following the recommended `.vimrc` configuration for ALE:

```
let g:ale_fixers = {
            \ '*': ['remove_trailing_lines', 'trim_whitespace'],
            \ 'markdown': ['prettier'],
            \ 'python': ['yapf'],
            \ 'yaml': ['prettier']
            \ }
let g:ale_linters = {
            \ 'python': ['flake8', 'pyls'],
            \ 'vim': ['vint']
            \ }
let g:ale_python_pyls_config = {
                          \   'pyls': {
                          \     'plugins': {
                          \       'pycodestyle': {
                          \         'enabled': v:false
                          \       }
                          \     }
                          \   },
                          \ }
```
