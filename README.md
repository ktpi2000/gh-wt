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
gh wt --help
```

## Commands

- `list` - List worktrees
- `add <branch> [path]` - Create worktree  
- `pr <number> [path]` - Create from PR
- `remove` - Remove worktree (interactive)
- `<command>` - Execute in selected worktree

