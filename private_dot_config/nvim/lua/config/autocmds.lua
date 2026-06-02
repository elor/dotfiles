-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local state_file = vim.fn.stdpath("data") .. "/last_update"

local function today()
  return tostring(os.date("%Y-%m-%d"))
end

local function last_update_date()
  local f = io.open(state_file, "r")
  if not f then
    return nil
  end
  local date = f:read("*l")
  f:close()
  return date
end

local function write_today()
  local f = io.open(state_file, "w")
  if f then
    f:write(today())
    f:close()
  end
end

local function auto_update()
  vim.notify("Auto-update: checking plugins...", vim.log.levels.INFO, { title = "Auto Update" })

  -- Update Lazy plugins
  require("lazy").update({
    show = false,
    on_update = function(plugin)
      vim.notify("Updating plugin: " .. plugin.name, vim.log.levels.INFO, { title = "Auto Update" })
    end,
    on_complete = function(results)
      local updated = #results.updated
      local errors = #results.errors
      if errors > 0 then
        vim.notify(
          "Plugins done — " .. updated .. " updated, " .. errors .. " errors",
          vim.log.levels.WARN,
          { title = "Auto Update" }
        )
      else
        vim.notify("Plugins done — " .. updated .. " updated", vim.log.levels.INFO, { title = "Auto Update" })
      end

      -- Chain Mason update after Lazy finishes
      vim.notify("Auto-update: checking Mason packages...", vim.log.levels.INFO, { title = "Auto Update" })
      vim.cmd("MasonUpdate")
      vim.notify("Mason update complete", vim.log.levels.INFO, { title = "Auto Update" })
    end,
  })
end

if last_update_date() ~= today() then
  write_today()
  vim.defer_fn(auto_update, 3000)
end
