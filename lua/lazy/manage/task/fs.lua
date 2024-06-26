local Config = require("lazy.core.config")
local Util = require("lazy.util")

---@type table<string, LazyTaskDef>
local M = {}

local function rm(dir)
  local stat = vim.uv.fs_lstat(dir)
  assert(stat and stat.type == "directory", dir .. " should be a directory!")
  Util.walk(dir, function(path, _, type)
    if type == "directory" then
      vim.uv.fs_rmdir(path)
    else
      vim.uv.fs_unlink(path)
    end
  end)
  vim.uv.fs_rmdir(dir)
end

M.clean = {
  skip = function(plugin)
    return plugin._.is_local
  end,
  run = function(self)
    local dir = self.plugin.dir:gsub("/+$", "")
    assert(dir:find(Config.options.root, 1, true) == 1, self.plugin.dir .. " should be under packpath!")
    rm(dir)

    local rock_root = Config.options.rocks.root .. "/" .. self.plugin.name
    if vim.uv.fs_stat(rock_root) then
      rm(rock_root)
    end

    self.plugin._.installed = false
  end,
}

return M
