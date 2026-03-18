local config = require 'chomp.config'

local M = {}

M.setup = function(options)
  config.set(options or {})

  require 'chomp.api.commands'
end

return M
