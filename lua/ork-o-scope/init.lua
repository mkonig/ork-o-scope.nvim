local config = require("ork-o-scope.config")
local scope_module = require("ork-o-scope.scope")
local highlight = require("ork-o-scope.highlight")

local M = {}

local autocmd_id = nil

local function clear_highlights()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, highlight.scope_ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(bufnr, highlight.all_scopes_ns, 0, -1)
end

local function update_scope_highlight()
  if not config.options.enabled then
    return
  end

  clear_highlights()

  if config.options.mode == "all_scopes" then
    highlight.highlight_all_scopes()
  else
    local scope = scope_module.get_current_scope()
    if scope then
      highlight.apply_scope_highlight(scope)
    end
  end
end

local function setup_autocommands()
  if autocmd_id then
    vim.api.nvim_del_augroup_by_id(autocmd_id)
  end

  autocmd_id = vim.api.nvim_create_augroup("OrkOScope", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = autocmd_id,
    callback = update_scope_highlight,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "TextChangedI" }, {
    group = autocmd_id,
    callback = function()
      if config.options.mode == "all_scopes" then
        update_scope_highlight()
      end
    end,
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = autocmd_id,
    callback = highlight.setup_highlights,
  })
end

function M.setup(opts)
  config.setup(opts)
  highlight.setup_highlights()

  if config.options.enabled then
    setup_autocommands()
  end
end

function M.enable()
  config.options.enabled = true
  setup_autocommands()
  update_scope_highlight()
end

function M.disable()
  config.options.enabled = false
  if autocmd_id then
    vim.api.nvim_del_augroup_by_id(autocmd_id)
    autocmd_id = nil
  end
  clear_highlights()
end

function M.toggle()
  if config.options.enabled then
    M.disable()
  else
    M.enable()
  end
end

function M.set_mode(mode)
  local valid_modes = { "full_line", "text_only", "box", "all_scopes" }
  if not vim.tbl_contains(valid_modes, mode) then
    vim.notify("Invalid mode: " .. mode, vim.log.levels.ERROR)
    return
  end
  config.options.mode = mode
  update_scope_highlight()
end

function M.get_mode()
  return config.options.mode
end

function M.is_enabled()
  return config.options.enabled
end

return M
