local M = {}

M.defaults = {
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
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
