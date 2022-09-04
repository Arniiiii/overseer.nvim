# overseer.nvim

A task runner and job management plugin for Neovim

**BETA** - [APIs](doc/reference.md#lua-api) are not guaranteed to be stable, but a best-effort will be made to retain backwards-compatibility

Please leave feedback about what's hard, what's confusing, and where the documentation is lacking. I have a lot of plans for overseer, but I prioritize what's next based on requests.

https://user-images.githubusercontent.com/506791/180620617-2b1bb0a8-5f39-4936-97c2-04c92f1e2974.mp4

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Tutorials](doc/tutorials.md)
  - [Build a C++ file](docs/tutorials.md#build-a-c++-file)
- [Guides](doc/guides.md)
  - [Custom tasks](doc/guides.md#custom-tasks)
  - [Actions](doc/guides.md#actions)
  - [Custom components](doc/guides.md#custom-components)
- [Reference](doc/reference.md)
  - [Setup options](doc/reference.md#setup-options)
  - [Commands](doc/reference.md#commands)
- [Explanation](doc/explanation.md)
  - [Architecture](doc/explanation.md#architecture)
    - [Tasks](doc/explanation.md#tasks)
    - [Components](doc/explanation.md#components)
    - [Templates](doc/explanation.md#templates)
  - [Task list](doc/explanation.md#task-list)
- [Third-party integrations](#third-party-integrations)
  - [Lualine](#lualine)
  - [Neotest](#neotest)
  - [DAP](#dap)
  - [Session managers](#session-managers)

## Features

- Built-in support for many task frameworks (make, npm, cargo, `.vscode/tasks.json`, etc)
- Simple integration with vim.diagnostics and quickfix
- UI for viewing and managing tasks
- Quick controls for common actions (restart task, rerun on save, or user-defined functions)
- Extreme customizability. Very easy to attach custom logic to tasks
- Define and run complex multi-stage workflows
- Support for `preLaunchTask` when used with [nvim-dap](https://github.com/mfussenegger/nvim-dap)

## Requirements

- Neovim 0.7+
- (optional) patches for `vim.ui` (e.g. [dressing.nvim](https://github.com/stevearc/dressing.nvim)). Provides nicer UI for input and selection.
- (optional) [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim). When used with [dressing.nvim](https://github.com/stevearc/dressing.nvim) provides best selection UI.
- (optional) [nvim-notify](https://github.com/rcarriga/nvim-notify) a nice UI for `vim.notify`

## Installation

overseer supports all the usual plugin managers

<details>
  <summary>Packer</summary>

```lua
require('packer').startup(function()
    use {
      'stevearc/overseer.nvim',
      config = function() require('overseer').setup() end
    }
end)
```

</details>

<details>
  <summary>Paq</summary>

```lua
require "paq" {
    {'stevearc/overseer.nvim'};
}
```

</details>

<details>
  <summary>vim-plug</summary>

```vim
Plug 'stevearc/overseer.nvim'
```

</details>

<details>
  <summary>dein</summary>

```vim
call dein#add('stevearc/overseer.nvim')
```

</details>

<details>
  <summary>Pathogen</summary>

```sh
git clone --depth=1 https://github.com/stevearc/overseer.nvim.git ~/.vim/bundle/
```

</details>

<details>
  <summary>Neovim native package</summary>

```sh
git clone --depth=1 https://github.com/stevearc/overseer.nvim.git \
  "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/overseer/start/overseer.nvim
```

</details>

## Quick start

Add the following to your init.lua

```lua
require('overseer').setup()
```

To get started, all you need to know is `:OverseerRun` to select and start a task, and `:OverseerToggle` to open the task list.

FIXME video of running a task, opening it, inspecting output.

If you don't see any tasks from `:OverseerRun`, it might mean that your task runner is not yet supported. There is currently support for VS Code tasks, make, npm, cargo, and some others. If yours is not supported, ([request support here](https://github.com/stevearc/overseer.nvim/issues/new/choose)).

If you want to define custom tasks for your project, I'd recommend starting with [the tutorials](doc/tutorials.md).

## Tutorials

- [Build a C++ file](docs/tutorials.md#build-a-c++-file)

## Guides

- [Custom tasks](doc/guides.md#custom-tasks)
- [Actions](doc/guides.md#actions)
- [Custom components](doc/guides.md#custom-components)

## Reference

- [Setup options](doc/reference.md#setup-options)
- [Commands](doc/reference.md#commands)

## Explanation

- [Architecture](doc/explanation.md#architecture)
  - [Tasks](doc/explanation.md#tasks)
  - [Components](doc/explanation.md#components)
  - [Templates](doc/explanation.md#templates)
- [Task list](doc/explanation.md#task-list)

## Third-party integrations

### Lualine

There is a drop-in lualine component available. Use like:

```lua
require("lualine").setup({
  sections = {
    lualine_x = { "overseer" },
  },
})
```

Or with options:

```lua
require("lualine").setup({
  sections = {
    lualine_x = { {
      "overseer",
      label = '',     -- Prefix for task counts
      colored = true, -- Color the task icons and counts
      symbols = {
        [overseer.STATUS.FAILURE] = "F:",
        [overseer.STATUS.CANCELED] = "C:",
        [overseer.STATUS.SUCCESS] = "S:",
        [overseer.STATUS.RUNNING] = "R:",
      },
      unique = false,     -- Unique-ify non-running task count by name
      name = nil,         -- List of task names to search for
      name_not = false,   -- When true, invert the name search
      status = nil,       -- List of task statuses to display
      status_not = false, -- When true, invert the status search
    } },
  },
})
```

### Neotest

To run all neotest processes using overseer, add it as a custom consumer:

```lua
require('neotest').setup({
  consumers = {
    overseer = require("neotest.consumers.overseer"),
  },
})
```

This will automatically hook `neotest.run` and force it to use overseer to run tests wherever possible. If you would instead like to only use the overseer consumer explicitly, you can disable the monkey patching:

```lua
require('neotest').setup({
  consumers = {
    overseer = require("neotest.consumers.overseer"),
  },
  overseer = {
    enabled = true,
    -- When this is true (the default), it will replace all neotest.run.* commands
    force_default = false,
  },
})

-- Now neotest.run is unchanged; to run tests with overseer use:
neotest.overseer.run({})
```

You can customize the default components of neotest tasks by setting the `default_neotest` component alias (when unset it maps to `default`).

```lua
require('overseer').setup({
  component_aliases = {
    default_neotest = {
      "on_output_summarize",
      "on_exit_set_status",
      "on_complete_notify",
      "on_complete_dispose",
    },
  }
})
```

### DAP

If you have both overseer and [nvim-dap](https://github.com/mfussenegger/nvim-dap) installed, overseer will automatically run the `preLaunchTask` and `postDebugTask` when present in a debug configuration.

### Session managers

If you would like to save and restore overseer tasks as part of saving and restoring a session, overseer makes that easy with task bundles. These are exposed to the user with the commands `:OverseerSaveBundle` and `:OverseerLoadBundle`, but you can use the lua API directly for a nicer integration. You essentially just need to get the session name and add some hooks using your plugin's API to handle overseer tasks on session save/restore.

For example, to integrate with [auto-session](https://github.com/rmagatti/auto-session)

```lua
-- Convert the cwd to a simple file name
local function get_cwd_as_name()
  local dir = vim.fn.getcwd(0)
  return dir:gsub("[^A-Za-z0-9]", "_")
end
local overseer = require("overseer")
require("auto-session").setup({
  pre_save_cmds = {
    function()
      overseer.save_task_bundle(
        get_cwd_as_name(),
        overseer.list_tasks({
          bundleable = true, -- Ignore tasks that shouldn't be bundled
          -- See other filter options to only save certain tasks
        }),
        { on_conflict = "overwrite" } -- Overwrite existing bundle, if any
      )
    end,
  },
  post_restore_cmds = {
    function()
      overseer.load_task_bundle(get_cwd_as_name(), { ignore_missing = true })
    end,
  },
})
```
