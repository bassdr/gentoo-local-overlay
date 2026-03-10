#!/usr/bin/env bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

parts=()
[ -n "$cwd" ] && parts+=("$(basename "$cwd")")
[ -n "$model" ] && parts+=("$model")
[ -n "$used" ] && parts+=("ctx: ${used}%")

printf '%s' "$(IFS=' | '; echo "${parts[*]}")"
