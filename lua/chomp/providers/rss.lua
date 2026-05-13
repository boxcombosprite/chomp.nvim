local xml = require 'chomp.util.xml'

local Base = {}
Base.__index = Base

---@class Rss20
---@field _title string
---@field _updated string|nil
---@field _els table[]
---@field _items_from integer
---@field _doc XmlDocument
local Rss20 = setmetatable({}, Base)
Rss20.__index = Rss20

---@protected
Rss20.find_chann_el = function(self)
  if not self._doc then vim.notify('tried parsing feed with unitialized parser', 'error') end
  for _, k in ipairs(self._doc.kids) do
    if k.name == 'rss' then
      for _, j in ipairs(k.el) do
        if j.name == 'channel' then return j end
      end
    end
  end
end

Rss20.new = function(doc)
  local self = setmetatable({ _doc = doc }, Rss20)

  local channel = self:find_chann_el()
  if not channel then error 'no <feed> element' end

  local channel_els = channel.el
  local i = 1
  while channel_els[i] and channel_els[i].name ~= 'item' do
    i = i + 1
  end

  local meta = xml.extract({ 'title', 'lastBuildDate' }, { table.unpack(channel_els, 1, i - 1) })
  self._title = meta.title
  self._updated = meta.lastBuildDate
  self._items_from = i
  self._els = channel_els

  return self
end

Rss20.get_title = function(self) end

Rss20.get_updated = function(self) end

Rss20.posts = function(self) end

return {
  ['2.0'] = Rss20,
}
