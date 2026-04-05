local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local telescope_utils = require('telescope.utils')
local conf = require('telescope.config').values

local workspaces = require('mini-workspaces')

local switch_workspace = function(prompt_bufnr)
  local path = action_state.get_selected_entry(prompt_bufnr).path
  actions.close(prompt_bufnr)

  if path ~= nil then
    workspaces.open_workspace(path)
  end
end

local telescope_list_workspaces = function(opts)
  opts = opts or {}

  local entries = workspaces.history()
  if entries == nil then
    return
  end

  local widths = {
    label = 0,
    path = 0,
  }

  for _, e in ipairs(entries) do
    widths.label = math.max(widths.label, #e.label)
    widths.path = math.max(widths.path, #e.path)
  end

  local displayer = require('telescope.pickers.entry_display').create({
    separator = ' ',
    items = {
      { width = widths.branch },
      { width = widths.label },
      { width = widths.path },
    },
  })

  local make_display = function(entry)
    return displayer({
      { entry.label, 'TelescopeResultsIdentifier' },
      {
        telescope_utils.transform_path(opts, entry.path),
        'TelescopeResultsField',
      },
    })
  end

  pickers
    .new(opts or {}, {
      prompt_title = 'Git Worktrees',
      finder = finders.new_table({
        results = entries,
        entry_maker = function(entry)
          entry.value = entry.path
          entry.ordinal = entry.label
          entry.display = make_display
          return entry
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(_, _)
        actions.select_default:replace(switch_workspace)
        return true
      end,
    })
    :find()
end

return require('telescope').register_extension({
  exports = {
    list_workspaces = telescope_list_workspaces,
  },
})
