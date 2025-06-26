#!/usr/bin/env bash

check_dependencies() {
    local missing_deps=()
    
    if ! command -v gh >/dev/null 2>&1; then
        missing_deps+=("gh (GitHub CLI)")
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        missing_deps+=("fzf")
    fi
    
    if ! command -v git >/dev/null 2>&1; then
        missing_deps+=("git")
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Error: Missing required dependencies:" >&2
        printf '  - %s\n' "${missing_deps[@]}" >&2
        echo "" >&2
        echo "Please install the missing dependencies and try again." >&2
        exit 1
    fi
}

check_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        exit 1
    fi
}

get_repo_root() {
    git rev-parse --show-toplevel
}

get_current_branch() {
    git branch --show-current
}