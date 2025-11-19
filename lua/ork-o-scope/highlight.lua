local config = require("ork-o-scope.config")
local scope_module = require("ork-o-scope.scope")

local M = {}

M.scope_ns = vim.api.nvim_create_namespace("ork_o_scope_current")
M.all_scopes_ns = vim.api.nvim_create_namespace("ork_o_scope_all")

local depth_highlights = {
  "OrkOScopeDepth0",
  "OrkOScopeDepth1",
  "OrkOScopeDepth2",
  "OrkOScopeDepth3",
  "OrkOScopeDepth4",
  "OrkOScopeDepth5",
  "OrkOScopeDepth6",
  "OrkOScopeDepth7",
}

function M.setup_highlights()
  local opts = config.options

  for i = 0, 7 do
    local depth_key = "depth" .. i
    local hl_name = "OrkOScopeDepth" .. i
    local color = opts.colors[depth_key]
    vim.api.nvim_set_hl(0, hl_name, { bg = color })
  end
end

local function highlight_full_line(start_row, end_row)
  for i = start_row, end_row do
    vim.api.nvim_buf_set_extmark(0, M.scope_ns, i, 0, {
      line_hl_group = "CursorLine",
    })
  end
end

local function highlight_text_only(start_row, end_row)
  vim.highlight.range(0, M.scope_ns, "CursorLine", { start_row, 0 }, { end_row, 0 }, {})
end

local function highlight_box(start_row, end_row)
  local min_col = math.huge
  local max_col = 0

  for i = start_row, end_row do
    local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1] or ""
    local first_char = line:match("^%s*()")
    if first_char and #line > 0 then
      min_col = math.min(min_col, first_char - 1)
      max_col = math.max(max_col, #line)
    end
  end

  if min_col >= math.huge or max_col == 0 then
    return
  end

  for i = start_row, end_row do
    local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1] or ""
    local line_len = #line

    if line_len > 0 then
      local start_col = math.min(min_col, line_len)
      local end_col = math.max(start_col, line_len)

      vim.api.nvim_buf_set_extmark(0, M.scope_ns, i, start_col, {
        end_col = end_col,
        hl_group = "CursorLine",
      })

      if line_len < max_col then
        local padding = string.rep(" ", max_col - line_len)
        vim.api.nvim_buf_set_extmark(0, M.scope_ns, i, line_len, {
          virt_text = { { padding, "CursorLine" } },
          virt_text_pos = "overlay",
        })
      end
    else
      vim.api.nvim_buf_set_extmark(0, M.scope_ns, i, 0, {
        virt_text = {
          { string.rep(" ", min_col), "" },
          { string.rep(" ", max_col - min_col), "CursorLine" },
        },
        virt_text_pos = "overlay",
      })
    end
  end
end

function M.highlight_all_scopes()
  local bufnr = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_clear_namespace(bufnr, M.all_scopes_ns, 0, -1)

  local scopes = scope_module.get_all_scopes()
  if #scopes == 0 then
    return
  end

  local max_depth = 0
  for _, s in ipairs(scopes) do
    local d = scope_module.get_scope_depth(s, scopes)
    max_depth = math.max(max_depth, d)
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local scope_data = {}

  for _, scope in ipairs(scopes) do
    local depth = scope_module.get_scope_depth(scope, scopes)
    local hl_group = depth_highlights[(depth % #depth_highlights) + 1]
    local start_row = scope.start_row
    local end_row = scope.end_row

    if start_row == end_row then
      goto skip_scope
    end

    local min_col = math.huge
    local max_col = 0

    for i = start_row, end_row do
      local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1] or ""
      local first_char = line:match("^%s*()")
      if first_char and #line > 0 then
        min_col = math.min(min_col, first_char - 1)
        max_col = math.max(max_col, #line)
      end
    end

    local right_margin = max_depth - depth + 1
    max_col = max_col + right_margin

    if min_col < math.huge and max_col > 0 then
      table.insert(scope_data, {
        start_row = start_row,
        end_row = end_row,
        min_col = min_col,
        max_col = max_col,
        hl_group = hl_group,
        depth = depth,
        priority = 100 + depth,
      })
    end

    ::skip_scope::
  end

  for line_idx = 0, line_count - 1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, line_idx, line_idx + 1, false)[1] or ""
    local line_len = #line

    local scopes_on_line = {}
    for _, sd in ipairs(scope_data) do
      if line_idx >= sd.start_row and line_idx <= sd.end_row then
        table.insert(scopes_on_line, sd)
      end
    end

    if #scopes_on_line == 0 then
      goto continue
    end

    table.sort(scopes_on_line, function(a, b)
      return a.depth < b.depth
    end)

    for _, sd in ipairs(scopes_on_line) do
      local start_col = math.min(sd.min_col, math.max(line_len, sd.min_col))
      local end_col = math.max(start_col, line_len)

      if end_col > start_col then
        vim.api.nvim_buf_set_extmark(bufnr, M.all_scopes_ns, line_idx, start_col, {
          end_col = end_col,
          hl_group = sd.hl_group,
          priority = sd.priority,
        })
      end
    end

    local segments = {}
    local positions = {}

    if line_len == 0 then
      table.insert(positions, 0)
      for _, sd in ipairs(scopes_on_line) do
        if not vim.tbl_contains(positions, sd.min_col) then
          table.insert(positions, sd.min_col)
        end
        if not vim.tbl_contains(positions, sd.max_col) then
          table.insert(positions, sd.max_col)
        end
      end
    else
      table.insert(positions, line_len)
      for _, sd in ipairs(scopes_on_line) do
        if sd.max_col > line_len and not vim.tbl_contains(positions, sd.max_col) then
          table.insert(positions, sd.max_col)
        end
      end
    end

    table.sort(positions)

    for i = 1, #positions - 1 do
      local start_pos = positions[i]
      local end_pos = positions[i + 1]
      local width = end_pos - start_pos

      local hl_group = nil
      for j = #scopes_on_line, 1, -1 do
        local sd = scopes_on_line[j]
        if sd.min_col <= start_pos and sd.max_col >= end_pos then
          hl_group = sd.hl_group
          break
        end
      end

      if width > 0 then
        table.insert(segments, { string.rep(" ", width), hl_group or "" })
      end
    end

    if #segments > 0 then
      local virt_col = line_len == 0 and 0 or line_len
      vim.api.nvim_buf_set_extmark(bufnr, M.all_scopes_ns, line_idx, virt_col, {
        virt_text = segments,
        virt_text_pos = "overlay",
        priority = 1000,
      })
    end

    ::continue::
  end
end

local highlight_modes = {
  full_line = highlight_full_line,
  text_only = highlight_text_only,
  box = highlight_box,
  all_scopes = M.highlight_all_scopes,
}

function M.apply_scope_highlight(scope)
  local mode = config.options.mode

  if mode == "all_scopes" then
    M.highlight_all_scopes()
  else
    local start_row, end_row = scope_module.adjust_scope_for_conditionals(scope)
    local highlight_fn = highlight_modes[mode]
    if highlight_fn then
      highlight_fn(start_row, end_row)
    end
  end
end

return M
