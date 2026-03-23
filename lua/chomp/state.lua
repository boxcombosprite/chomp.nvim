local db = require 'chomp.db'
local util = require 'chomp.util'

local M = {}

local state = {}

M.set = function(s)
  state = vim.tbl_deep_extend('force', state, s or {})
  return state
end

M.load = function()
  state = db.load() or {}
  return state
end

M.dump = function() db.save(state) end

M.mark_read = function(feed, id)
  if state.feeds and state.feeds[feed] then table.insert(state.feeds[feed].read, id) end
end

local new_feed = function(url)
  local data = util.http.get(url)
  local _parser = util.parser.new(db.cache.save_feed(data.xml))

  return {
    title = _parser:title(),
    last_updated = _parser:last_updated(),
    etag = data.etag,
    read = {},
    posts = _parser:posts(),
  }
end

M.sync_feeds = function(urls)
  local feeds_tmp = {}
  for u in urls do
    local normalized = util.url.normalize(u)
    feeds_tmp = state.feeds[normalized] or new_feed(normalized)
  end
  state.feeds = feeds_tmp
end

M.get_post = function(id) end

M.is_updated = function(url) end

M.current = state

return M
