local M = {}

---@type Options
local default_options = {}

M.setup = function(options)
  local opts = vim.tbl_deep_extend('force', default_options, options or {})

  require 'chomp.api.commands'
end

return M
