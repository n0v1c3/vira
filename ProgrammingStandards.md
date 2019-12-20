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

## Markdown

## Python

## Vimscript

# Auto-formatters

## General

## Markdown

## Python

## Vimscript

# Vim ALE Plugin (Optional)
