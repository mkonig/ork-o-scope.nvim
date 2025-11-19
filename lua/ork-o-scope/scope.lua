local config = require("ork-o-scope.config")

local M = {}

local function find_smallest_scope(root, row, scope_types)
  local on_start_line = {}
  local not_on_start = {}

  local function traverse(node)
    if not node then
      return
    end

    local type = node:type()
    local start_row, _, end_row, _ = node:range()

    if scope_types[type] and row >= start_row and row <= end_row then
      local match = {
        type = type,
        node = node,
        start_row = start_row,
        end_row = end_row,
        size = end_row - start_row,
      }

      if start_row == row then
        table.insert(on_start_line, match)
      else
        table.insert(not_on_start, match)
      end
    end

    for child in node:iter_children() do
      traverse(child)
    end
  end

  traverse(root)

  local candidates = #on_start_line > 0 and on_start_line or not_on_start
  if #candidates == 0 then
    return nil
  end

  table.sort(candidates, function(a, b)
    return a.size < b.size
  end)

  local smallest = candidates[1]

  for _, candidate in ipairs(candidates) do
    if
      candidate.type == "else_statement"
      or candidate.type == "else_clause"
      or candidate.type == "elif_clause"
      or candidate.type == "elseif_statement"
      or candidate.type == "except_clause"
    then
      return candidate
    end
  end

  return smallest
end

function M.get_all_scopes()
  local bufnr = vim.api.nvim_get_current_buf()

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return {}
  end

  local tree = parser:parse()[1]
  local root = tree:root()
  local scopes = {}
  local scope_types = config.options.scope_types

  local function traverse(node)
    if not node then
      return
    end

    local type = node:type()
    if scope_types[type] then
      if
        type ~= "elseif_statement"
        and type ~= "else_statement"
        and type ~= "elif_clause"
        and type ~= "else_clause"
        and type ~= "except_clause"
      then
        local start_row, _, end_row, _ = node:range()
        table.insert(scopes, {
          type = type,
          node = node,
          start_row = start_row,
          end_row = end_row,
          size = end_row - start_row,
        })
      end
    end

    for child in node:iter_children() do
      traverse(child)
    end
  end

  traverse(root)
  return scopes
end

function M.get_current_scope()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local bufnr = vim.api.nvim_get_current_buf()

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return nil
  end

  local tree = parser:parse()[1]
  local root = tree:root()
  local scope_types = config.options.scope_types

  return find_smallest_scope(root, row, scope_types)
end

function M.adjust_scope_for_conditionals(scope)
  local start_row, _, end_row, _ = scope.node:range()

  if scope.type == "if_statement" then
    for child in scope.node:iter_children() do
      local child_type = child:type()
      local child_start, _, _, _ = child:range()
      if
        (
          child_type == "elseif_statement"
          or child_type == "else_statement"
          or child_type == "elif_clause"
          or child_type == "else_clause"
        ) and child_start > start_row
      then
        return start_row, child_start - 1
      end
    end
  elseif scope.type == "elseif_statement" or scope.type == "elif_clause" then
    local parent = scope.node:parent()
    if parent then
      local found_current = false
      for sibling in parent:iter_children() do
        if sibling == scope.node then
          found_current = true
        elseif found_current then
          local sib_type = sibling:type()
          local sib_start, _, _, _ = sibling:range()
          if
            sib_type == "elseif_statement"
            or sib_type == "else_statement"
            or sib_type == "elif_clause"
            or sib_type == "else_clause"
          then
            return start_row, sib_start - 1
          end
        end
      end
    end
  elseif scope.type == "else_statement" or scope.type == "else_clause" then
    return start_row, end_row
  elseif scope.type == "try_statement" then
    for child in scope.node:iter_children() do
      local child_type = child:type()
      local child_start, _, _, _ = child:range()
      if child_type == "except_clause" and child_start > start_row then
        return start_row, child_start - 1
      end
    end
  elseif scope.type == "except_clause" then
    local parent = scope.node:parent()
    if parent then
      local found_current = false
      for sibling in parent:iter_children() do
        if sibling == scope.node then
          found_current = true
        elseif found_current then
          local sib_type = sibling:type()
          local sib_start, _, _, _ = sibling:range()
          if sib_type == "except_clause" then
            return start_row, sib_start - 1
          end
        end
      end
    end
    return start_row, end_row
  end

  return start_row, end_row
end

function M.get_scope_depth(scope, all_scopes)
  local depth = 0
  local scope_types = config.options.scope_types

  for _, other in ipairs(all_scopes) do
    if
      other ~= scope
      and other.start_row <= scope.start_row
      and other.end_row >= scope.end_row
      and scope_types[other.type]
    then
      depth = depth + 1
    end
  end
  return depth
end

return M
