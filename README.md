# Mini Workspaces

Plugin to improve local directory sessions experience with [`mini.sessions`](https://github.com/nvim-mini/mini.sessions).

The plugin takes care of managing local sessions, properly transitioning between them and storing recent workspaces history.

Initial motivation of the plugin is to provide a better integration for [worktrees.nvim](https://github.com/juksuu/worktrees.nvim).

## TODOs

- [ ] Automatically sync workspaces history using `mini.sessions` hooks.

## Installation

Plugin requires `mini.nvim` or `mini.sessions` to be installed.

<details>
<summary>With <a href="https://github.com/folke/lazy.nvim">folke/lazy.nvim</a></summary>

```lua
{
    'x1unix/mini-workspaces',
    dependencies = {
        -- Or use 'nvim-mini/mini.sessions'.
        'nvim-mini/mini.nvim',
        opts = { ... }
    },
    opts = {
        -- Plugin config
    }
}
```

</details>

**Important: don't forget to call `require('mini-workspaces')` to enable its functionality.**

## Default config

```lua
-- No need to copy this inside `setup()`. Will be used automatically.
{
    -- Location of a file with recent workspaces history. Used for `mini.starter` integration.
    -- Setting this to empty string ('') disables recent workspaces history.
    history_file = vim.fs.joinpath(vim.fn.stdpath('data'), 'workspaces.json'),

    -- Max number of items in history.
    history_max_items = 5,
}
```

## Usage

### Commands

- `MiniWorkspacesSave` - Create or update a local session in a current working directory and add workspace to a history.
- `MiniWorkspacesOpen` - Restore local session in a given directory.
  - Example: `:MiniWorkspacesOpen /path/to/dir`

## Integration

### Show recent workspaces in `mini.starter`

```lua
require('mini-workspaces').setup()

require('mini.starter').setup({
    items = {
        require('mini-workspaces.starter').history(),

        -- Rest of sections
        starter.sections.builtin_actions()
    }
})
```

### Session save dialog

The plugin provides a helper function to save current session either as a local (workspace) or a global session.

```lua
require('mini-workspaces.ui').save_session_dialog()
```

### Telescope

1. Load the extension

```lua
require('telescope').load_extension('workspaces')
```

2. Call the picker to switch a workspace:

```lua
require('telescope').extensions.worktrees.list_worktrees()
```

### Snacks.nvim

```lua
-- Switch between workspaces
Snacks.picker.workspaces()

-- Pick and delete workspace
Snacks.picker.workspaces_remove()
```

### Per-worktree session management using [`worktrees.nvim`](https://github.com/Juksuu/worktrees.nvim)

Example with lazy.vim package manager:

```lua
return {
  {
    'Juksuu/worktrees.nvim',
    branch = 'feat/on-before-switch',
    keys = {
      {
        'gW',
        mode = { 'n' },
        function()
          Snacks.picker.worktrees()
        end,
        desc = 'git: switch worktree',
      },
    },
    opts = {
      -- Important: prevent conflict with session restoration.
      swap_current_buffer = false,

      hooks = {
        on_before_switch = function(from, to, git_path_info)
          -- Persist workspace session
          require('mini-workspaces').save_workspace(from, {
            force = true,
            wipeout = true,
            metadata = {
              -- Append parent directory name to history entry.
              label = require('mini-workspaces.utils').get_path_segments(from, 2),
            },
          })
        end,
        on_switch = function(from, to, git_path_info)
          -- Restore session
          require('mini-workspaces').open_workspace(to, {
            create_if_missing = true,
            on_created = require('util.uiutil').open_readme,
            metadata = {
              -- Append parent directory name to history entry.
              label = require('mini-workspaces.utils').get_path_segments(from, 2),
            },
          })
        end,
        on_before_remove = function(path)
          require('mini-workspaces').delete_workspace(path, { force = true })
        end,
      },
    },
  },
}
```
