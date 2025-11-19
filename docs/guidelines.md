# Development Guidelines

## When Editing Lua Files

- Always follow the code style in AGENTS.md
- No comments unless absolutely necessary
- Use 2-space indentation
- Module pattern: `local M = {}` ... `return M`

## When Modifying lefthook.yml

- Always update shell.nix to include the required tools
- Update shellHook echo messages
- Update AGENTS.md with the tool list
