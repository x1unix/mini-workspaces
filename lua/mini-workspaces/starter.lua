local M = {}

--- @param msg string
local function placeholder_entry(msg)
  return {
    {
      name = msg,
      action = '',
      section = 'Workspaces',
    },
  }
end

-- Returns workspaces list section for mini.starter
M.history = function()
  local workspaces = require('mini-workspaces')
  if not workspaces._ready then
    return placeholder_entry([[Workspaces plugin is not set up]])
  end

  if workspaces.config.history_file == '' then
    return placeholder_entry([[Workspaces history has been disabled]])
  end

  local entries = workspaces.history()
  if not entries or #entries == 0 then
    return placeholder_entry([[History is empty]])
  end

  local out = {}

  local sections = vim.tbl_map(function(entry)
    return {
      name = entry.label,
      action = 'MiniWorkspacesOpen ' .. vim.fn.fnameescape(entry.path),
      section = 'Recent workspaces',
    }
  end, entries)
  return sections
end

return M
