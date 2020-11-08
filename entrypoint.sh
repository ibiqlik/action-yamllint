#!/bin/bash -l

echo "======================"
echo "= Linting YAML files ="
echo "======================"

if [[ -n "$INPUT_CONFIG_FILE" ]]; then
    options+=(-c "$INPUT_CONFIG_FILE")
fi

if [[ -n "$INPUT_CONFIG_DATA" ]]; then
    options+=(-d "$INPUT_CONFIG_DATA")
fi

options+=(-f "$INPUT_FORMAT")

if [[ "$INPUT_STRICT" == "true" ]]; then
    options+=(-s)
fi

# Enable globstar so ** globs recursively
shopt -s globstar
# Use the current directory by default
options+=("${INPUT_FILE_OR_DIR:-.}")
shopt -u globstar

yamllint "${options[@]}"
