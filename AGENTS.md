# OpenCode Agent Configuration

This file contains instructions for OpenCode AI agents working on this project.

## General Guidelines

- Read existing code thoroughly before making changes
- Maintain consistency with the existing code style
- Avoid adding comments to Lua code unless absolutely necessary for complex logic
- Test changes by reloading the plugin using `:Lazy reload ork-o-scope.nvim`

## Development Environment

### shell.nix and lefthook.yml Synchronization

**CRITICAL**: When modifying `lefthook.yml` to add or remove pre-commit hooks:

1. Update `shell.nix` to include all tools referenced in lefthook commands
1. Update the `shellHook` echo messages to reflect available tools
1. Ensure every tool in lefthook has a corresponding package in `buildInputs`

Current tools required by lefthook:

- stylua (Lua formatter)
- luacheck (Lua linter)
- markdownlint-cli (Markdown linter)
- pyspelling (Spell checker)
- nixpkgs-fmt (Nix formatter)
- lefthook (Git hooks manager)
- cocogitto (Conventional commits)

## Plugin Architecture

### Core Modules

1. **config.lua** - Configuration management

   - Defines default options
   - Handles user configuration merging via `setup()`

1. **scope.lua** - Scope detection logic

   - Uses Tree-sitter to find scopes
   - Handles special cases for conditionals (if/else/elif/except)
   - Calculates scope depth for nesting

1. **highlight.lua** - Visual highlighting

   - Manages highlight namespaces and groups
   - Implements different highlight modes (full_line, text_only, box, all_scopes)
   - Sets up color schemes

1. **init.lua** - Main entry point

   - Exports public API
   - Sets up autocommands for cursor movement
   - Manages plugin enable/disable state

1. **plugin/ork-o-scope.lua** - Auto-loaded plugin file

   - Defines user commands
   - Provides plugin guard

## Development Workflow

1. Make changes to Lua files in `lua/ork-o-scope/`
1. Reload plugin: `:Lazy reload ork-o-scope.nvim`
1. Test changes in a buffer with Tree-sitter support
1. Use `:OrkOScopeMode` to test different modes

## Code Style

- Use 2-space indentation
- Local functions before public functions
- Early returns for error conditions
- Descriptive variable names
- Module pattern: `local M = {}` ... `return M`

## Testing

When testing changes:

- Test with Lua files (if/elseif/else)
- Test with Python files (if/elif/else, try/except)
- Test all four highlight modes
- Test toggling on/off
- Verify performance with large files

### Debugging

- Use `:InspectTree` to view Tree-sitter AST
- Check scope detection: `:lua vim.print(require("ork-o-scope.scope").get_current_scope())`
- View all scopes: `:lua vim.print(require("ork-o-scope.scope").get_all_scopes())`
