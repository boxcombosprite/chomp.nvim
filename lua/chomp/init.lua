local M = {}

---@type Options
local default_options = {}

local config = {}

M.setup = function(options)
  local opts = vim.tbl_deep_extend('force', default_options, options or {})
  config = opts
end

return M

-- vim: ts=2 sts=2 sw=2 et
