local config = require 'chomp.config'
local state = require 'chomp.state'
local util = require 'chomp.util'

local M = {}

M.setup = function(opts)
  config.set(opts or {})
  local _config = config.current
  local _state = state.load()

  -- config feeds are definitive
  _state.sync_feeds(_config.feeds)
  _state.dump()

  require 'chomp.api.commands'
end

return M
