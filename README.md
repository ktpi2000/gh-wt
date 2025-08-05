# gh-wt

A GitHub CLI extension for interactive git worktree management with fzf integration.

## Features

- 🚀 **One-command worktree creation** - `gh wt add feature-branch` or `gh wt pr 123` instantly creates ready-to-use worktrees
- 🔍 **Interactive everything** - Use fzf to select worktrees for any operation - no more typing paths
- 🧹 **Clean management** - Easy removal and dependency checking with clear error messages

## Installation

```bash
# Install dependencies
brew install gh fzf jq  # macOS
# or
sudo apt install gh fzf jq  # Ubuntu/Debian

# Install extension
gh extension install ktpi2000/gh-wt
```

## Usage

```bash
$ gh wt --help
gh-wt: Git Worktree management extension for GitHub CLI

USAGE:
    gh wt <command> [options]

COMMANDS:
    list                    List worktrees in current repository
    add <branch> [path]     Create a new worktree for a branch
    pr <number> [path]      Create worktree from PR number
    remove                  Remove a worktree interactively
    clean-merged            Find and delete merged branches interactively
    -- <command>            Execute command in selected worktree
    <command>               Execute command in selected worktree (interactive)
    help                    Show this help message

EXAMPLES:
    gh wt list
    gh wt add new-branch
    gh wt add new-branch ../my-feature
    gh wt pr 123
    gh wt remove
    gh wt clean-merged
    gh wt code              # Select worktree and open in VS Code
    gh wt git status        # Select worktree and run git status
    gh wt -- git status     # Same as above
```

## Commands

- `list` - List worktrees
- `add <branch> [path]` - Create worktree  
- `pr <number> [path]` - Create from PR
- `remove` - Remove worktree (interactive)
- `clean-merged` - Find and delete merged branches (interactive)
- `<command>` - Execute in selected worktree

