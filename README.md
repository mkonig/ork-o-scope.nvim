# ork-o-scope.nvim

> This plugin was developed by Claude 2.5 Sonnet via [OpenCode](https://opencode.ai),
> in collaboration with the project owner

A Neovim plugin that highlights the current scope (or all scopes) using Tree-sitter,
helping you stay oriented in your code.

## Features

- Highlight current scope at cursor position
- Multiple highlight modes: full line, text only, box, or all scopes
- Depth-based color coding for nested scopes
- Support for Lua and Python conditional structures (if/else/elif/except)
- Configurable scope types
- Pre-configured with sensible default colors

## Requirements

- Neovim 0.9+
- Tree-sitter support for your language

## Installation

### lazy.nvim

```lua
{
  "mkonig/ork-o-scope.nvim",
  config = function()
    require("ork-o-scope").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "mkonig/ork-o-scope.nvim",
  config = function()
    require("ork-o-scope").setup()
  end,
}
```

## Configuration

```lua
require("ork-o-scope").setup({
  enabled = true,
  mode = "box",
  scope_types = {
    function_definition = false,
    method_definition = true,
    function_declaration = false,
    if_statement = true,
    elseif_statement = true,
    else_statement = true,
    elif_clause = true,
    else_clause = true,
    for_statement = true,
    while_statement = true,
    repeat_statement = true,
    do_statement = true,
    try_statement = true,
    except_clause = true,
  },
  colors = {
    depth0 = "#e3e3e3",
    depth1 = "#b9b9b9",
    depth2 = "#ababab",
    depth3 = "#b9b9b9",
    depth4 = "#ababab",
    depth5 = "#b9b9b9",
    depth6 = "#ababab",
    depth7 = "#f7f7f7",
  },
})
```

### Options

- `enabled` (boolean):
  Enable or disable the plugin on startup
- `mode` (string):
  Highlight mode
  - `"full_line"`:
    Highlight entire lines
  - `"text_only"`:
    Highlight only text content
  - `"box"`:
    Highlight as a box around content
  - `"all_scopes"`:
    Highlight all scopes with depth-based colors
- `scope_types` (table):
  Which Tree-sitter node types to consider as scopes
- `colors` (table):
  Custom colors for each depth level (depth0-depth7)
  - Defaults to grayscale colors that work well on light backgrounds
  - Override with custom hex strings (e.g., `"#1e1e1e"`) as needed

## Commands

- `:OrkOScopeToggle` -
  Toggle scope highlighting on/off
- `:OrkOScopeEnable` -
  Enable scope highlighting
- `:OrkOScopeDisable` -
  Disable scope highlighting
- `:OrkOScopeMode [mode]` -
  Set or display current highlight mode
  - No arguments:
    Display current mode
  - With argument:
    Set mode (full_line, text_only, box, all_scopes)

## API

```lua
local ork = require("ork-o-scope")

ork.toggle()
ork.enable()
ork.disable()
ork.set_mode("all_scopes")
ork.get_mode()
ork.is_enabled()
```

## Highlight Modes

### full_line

Highlights the entire line from column 0 to end.

### text_only

Highlights only the text content, excluding leading whitespace.

### box

Highlights text as a rectangular box, aligning all lines within the scope.

### all_scopes

Highlights all scopes simultaneously with depth-based colors:

- Deeper scopes have higher priority
- Colors cycle through depth0-depth7
- Right margin increases with nesting depth

## Supported Languages

The plugin works with any language that has Tree-sitter support and defines scope node types.
Tested with:

- Lua
- Python
- JavaScript/TypeScript
- Rust
- Go
- And more

## License

MIT
