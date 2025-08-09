#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

cmd_list() {
    check_git_repo
    echo "Worktrees in $(basename "$(get_repo_root)"):"
    git worktree list --porcelain | while read -r line; do
        if [[ $line == worktree* ]]; then
            path=${line#worktree }
            printf "  %s" "$path"
        elif [[ $line == branch* ]]; then
            branch=${line#branch refs/heads/}
            printf " [%s]" "$branch"
        elif [[ $line == HEAD* ]]; then
            printf " [HEAD]"
        elif [[ $line == "" ]]; then
            printf "\n"
        fi
    done
}

cmd_add() {
    local branch_name="$1"
    local path="$2"
    
    check_git_repo
    
    if [ -z "$branch_name" ]; then
        echo "Error: Branch name is required" >&2
        echo "Usage: gh wt add <branch-name> [path]" >&2
        exit 1
    fi
    
    if [ -z "$path" ]; then
        path="../$(basename "$(get_repo_root)")-$branch_name"
    fi
    
    if [ -d "$path" ]; then
        echo "Error: Directory '$path' already exists" >&2
        exit 1
    fi
    
    if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
        echo "Creating new branch '$branch_name'..."
        git checkout -b "$branch_name"
        git checkout -
    fi
    
    echo "Creating worktree at '$path' for branch '$branch_name'..."
    git worktree add "$path" "$branch_name"
    echo "Worktree created successfully!"
}

cmd_pr() {
    local pr_number="$1"
    local path="$2"
    
    check_git_repo
    
    if [ -z "$pr_number" ]; then
        echo "Error: PR number is required" >&2
        echo "Usage: gh wt pr <pr-number> [path]" >&2
        exit 1
    fi
    
    echo "Fetching PR #$pr_number information..."
    local pr_info
    pr_info=$(gh pr view "$pr_number" --json headRefName,headRepository,number 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "Error: Could not fetch PR #$pr_number" >&2
        exit 1
    fi
    
    local branch_name
    branch_name=$(echo "$pr_info" | jq -r '.headRefName')
    
    if [ -z "$path" ]; then
        path="../$(basename "$(get_repo_root)")-pr-$pr_number"
    fi
    
    if git worktree list | grep -q "$path"; then
        echo "Worktree for PR #$pr_number already exists at '$path'"
        echo "Switching to existing worktree..."
        cd "$path" || exit 1
        return 0
    fi
    
    if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
        echo "Fetching PR #$pr_number branch '$branch_name'..."
        gh pr checkout "$pr_number"
        git checkout -
    fi
    
    echo "Creating worktree at '$path' for PR #$pr_number (branch: $branch_name)..."
    git worktree add "$path" "$branch_name"
    echo "Worktree created successfully!"
}

cmd_remove() {
    check_git_repo
    
    local worktrees
    worktrees=$(git worktree list --porcelain | awk '/^worktree/ {path=$2} /^branch/ {branch=$2; gsub(/^refs\/heads\//, "", branch)} /^$/ {if (path != "'$(get_repo_root)'") print path " [" branch "]"}')
    
    if [ -z "$worktrees" ]; then
        echo "No additional worktrees found to remove"
        exit 0
    fi
    
    local selected
    selected=$(echo "$worktrees" | fzf --prompt="Select worktree to remove: " --height=10 --reverse)
    
    if [ -z "$selected" ]; then
        echo "No worktree selected"
        exit 0
    fi
    
    local path
    path=$(echo "$selected" | awk '{print $1}')
    
    echo "Removing worktree at '$path'..."
    git worktree remove "$path"
    echo "Worktree removed successfully!"
}

cmd_exec() {
    local use_selection="$1"
    shift
    local command_args=("$@")
    
    check_git_repo
    
    if [ "$use_selection" = "true" ]; then
        local worktrees
        worktrees=$(git worktree list --porcelain | awk '/^worktree/ {path=$2} /^branch/ {branch=$2; gsub(/^refs\/heads\//, "", branch)} /^$/ {print path " [" branch "]"}')
        
        local selected
        selected=$(echo "$worktrees" | fzf --prompt="Select worktree to execute command: " --height=10 --reverse)
        
        if [ -z "$selected" ]; then
            echo "No worktree selected"
            exit 0
        fi
        
        local path
        path=$(echo "$selected" | awk '{print $1}')
        
        echo "Executing command in worktree at '$path'..."
        cd "$path" || exit 1
    fi
    
    if [ ${#command_args[@]} -eq 0 ]; then
        echo "Error: No command specified" >&2
        exit 1
    fi
    
    exec "${command_args[@]}"
}

select_worktree() {
    local prompt="${1:-Select worktree: }"
    
    check_git_repo
    
    local worktrees
    worktrees=$(git worktree list --porcelain | awk '/^worktree/ {path=$2} /^branch/ {branch=$2; gsub(/^refs\/heads\//, "", branch)} /^$/ {print path " [" branch "]"}')
    
    if [ -z "$worktrees" ]; then
        echo "No worktrees found" >&2
        return 1
    fi
    
    local selected
    selected=$(echo "$worktrees" | fzf --prompt="$prompt" --height=10 --reverse)
    
    if [ -z "$selected" ]; then
        echo "No worktree selected" >&2
        return 1
    fi
    
    echo "$selected" | awk '{print $1}'
}

cmd_exec_with_selection() {
    local command_args=("$@")
    
    if [ ${#command_args[@]} -eq 0 ]; then
        echo "Error: No command specified" >&2
        exit 1
    fi
    
    local selected_path
    selected_path=$(select_worktree "Select worktree to execute '${command_args[*]}': ")
    
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    echo "Executing '${command_args[*]}' in worktree at '$selected_path'..."
    cd "$selected_path" || exit 1
    exec "${command_args[@]}"
}