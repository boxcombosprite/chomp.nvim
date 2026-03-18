local config = require 'chomp.config'

local M = {}

M.setup = function(opts)
  config.set(opts or {})

  require 'chomp.api.commands'
end

return M
