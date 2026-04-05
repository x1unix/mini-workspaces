-- Snacks.nvim integration
local workspaces = require('mini-workspaces')

---@module 'snacks'
---@type snacks.picker.Finder
function CustomFinder(_, _)
  local history = workspaces.history()
  if not history then
    history = {}
  end

  ---@async
  ---@param cb async fun(item: snacks.picker.finder.Item)
  return function(cb)
    for i, e in ipairs(history) do
      local item = {
        idx = i,
        text = e.label,
        file = e.path,
        preview = {
          text = e.path,
        },
        path = e.path,
      }

      cb(item)
    end
  end
end

---@type snacks.picker.Config
local Switch = {
  title = 'Workspaces',
  preview = 'preview',
  finder = CustomFinder,
}

---@param picker snacks.Picker
---@param item? snacks.picker.Item
function Switch.confirm(picker, item)
  picker:close()

  if item ~= nil then
    require('pkg.mini-session-workspaces').open_workspace(item.path)
  end
end

---@type snacks.picker.Config
local Remove = {
  title = 'Workspaces',
  preview = 'preview',
  finder = CustomFinder,
}

---@param picker snacks.Picker
---@param item? snacks.picker.Item
function Remove.confirm(picker, item)
  picker:close()

  if item ~= nil then
    require('pkg.mini-session-workspaces').delete_workspace(item.path)
  end
end

local M = {}

M.setup = function()
  if Snacks and pcall(require, 'snacks.picker') then
    Snacks.picker.sources.workspaces = Switch
    Snacks.picker.sources.workspaces_remove = Remove
  end
end

return M
