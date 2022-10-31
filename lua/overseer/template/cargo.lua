local constants = require("overseer.constants")
local overseer = require("overseer")
local TAG = constants.TAG

---@type overseer.TemplateDefinition
local tmpl = {
  priority = 60,
  params = {
    args = { type = "list", delimiter = " " },
  },
  builder = function(params)
    local cmd = { "cargo" }
    if params.args then
      cmd = vim.list_extend(cmd, params.args)
    end
    return {
      cmd = cmd,
      default_component_params = {
        errorformat = [[%Eerror: %\%%(aborting %\|could not compile%\)%\@!%m,]]
          .. [[%Eerror[E%n]: %m,]]
          .. [[%Inote: %m,]]
          .. [[%Wwarning: %\%%(%.%# warning%\)%\@!%m,]]
          .. [[%C %#--> %f:%l:%c,]]
          .. [[%E  left:%m,%C right:%m %f:%l:%c,%Z,]]
          .. [[%.%#panicked at \'%m\'\, %f:%l:%c]],
      },
    }
  end,
}

return {
  cache_key = function(opts)
    return vim.fn.fnamemodify(vim.fn.findfile("Cargo.toml", opts.dir .. ";"), ":p")
  end,
  condition = {
    callback = function(opts)
      if vim.fn.executable("cargo") == 0 then
        return false, 'Command "cargo" not found'
      end
      if vim.fn.findfile("Cargo.toml", opts.dir .. ";") == "" then
        return false, "No Cargo.toml file found"
      end
      return true
    end,
  },
  generator = function(opts, cb)
    local commands = {
      { args = { "build" }, tags = { TAG.BUILD } },
      { args = { "test" }, tags = { TAG.TEST } },
      { args = { "check" } },
      { args = { "doc" } },
      { args = { "clean" } },
      { args = { "bench" } },
      { args = { "update" } },
      { args = { "publish" } },
      { args = { "run" } },
    }
    local ret = {}
    for _, command in ipairs(commands) do
      table.insert(
        ret,
        overseer.wrap_template(
          tmpl,
          { name = string.format("cargo %s", table.concat(command.args, " ")), tags = command.tags },
          { args = command.args }
        )
      )
    end
    table.insert(ret, overseer.wrap_template(tmpl, { name = "cargo" }))
    cb(ret)
  end,
}
