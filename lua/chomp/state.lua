local db = require 'chomp.db'

local M = {}

local state = {}

M.set = function(s)
  state = vim.tbl_deep_extend('force', state, s or {})
  return state
end

M.get = function() return state end

M.dump = function() db.save(state) end

M.load = function()
  state = db.load() or {}
  return state
end

M.mark_read = function(feed, id)
  if state.feeds and state.feeds[feed] then table.insert(state.feeds[feed].read, id) end
end

return M
