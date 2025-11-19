if vim.g.loaded_ork_o_scope then
  return
end
vim.g.loaded_ork_o_scope = true

vim.api.nvim_create_user_command("OrkOScopeToggle", function()
  require("ork-o-scope").toggle()
end, {})

vim.api.nvim_create_user_command("OrkOScopeEnable", function()
  require("ork-o-scope").enable()
end, {})

vim.api.nvim_create_user_command("OrkOScopeDisable", function()
  require("ork-o-scope").disable()
end, {})

vim.api.nvim_create_user_command("OrkOScopeMode", function(opts)
  if opts.args == "" then
    local current_mode = require("ork-o-scope").get_mode()
    vim.notify("Current mode: " .. current_mode, vim.log.levels.INFO)
  else
    require("ork-o-scope").set_mode(opts.args)
  end
end, {
  nargs = "?",
  complete = function()
    return { "full_line", "text_only", "box", "all_scopes" }
  end,
})
