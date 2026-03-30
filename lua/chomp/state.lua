local db = require 'chomp.db'
local http = require 'chomp.util.http'
local url = require 'chomp.util.url'
local parser = require 'chomp.parser'

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

local new_feed = function(_url)
  local data
  http.get(_url, function(res, err)
    if res then data = res end
  end)
  if not data then return nil end
  local _parser = parser.new(db.cache.save_feed(data.xml))

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
    local normalized = url.normalize(u)
    feeds_tmp = state.feeds[normalized] or new_feed(normalized)
  end
  state.feeds = feeds_tmp
end

M.get_post = function(id) end

M.is_updated = function(_url) end

M.current = state

return M
