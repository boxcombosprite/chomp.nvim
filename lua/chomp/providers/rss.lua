local xml = require 'chomp.util.xml'

local Base = {}
Base.__index = Base

---@class Rss20
---@field _title string
---@field _updated string?
---@field _els table<XmlElement>
---@field _items_from integer
---@field _doc XmlDocument
local Rss20 = setmetatable({}, Base)
Rss20.__index = Rss20

---@protected
Rss20.find_chann_el = function(self)
  if not self._doc then
    vim.notify('tried parsing feed with unitialized parser', 'error')
    return
  end
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

  local meta = xml.extract({
    title = { dst = '_title', func = xml.get_element_text },
    lastBuildDate = { dst = '_updated', func = xml.get_element_text },
  }, { table.unpack(channel_els, 1, i - 1) })

  self = vim.tbl_extend('force', self, meta)
  self._items_from = i
  self._els = channel_els

  return self
end

Rss20.get_title = function(self) return self._title end

Rss20.get_updated = function(self) return self._updated end

---@return fun(): Post?
Rss20.posts = function(self)
  local i = self._items_from - 1

  local value_mappings = {
    title = { dst = 'title', func = xml.get_element_text },
    link = { dst = 'url', func = xml.get_element_text },
    guid = { dst = 'guid', func = xml.get_element_text },
    description = { dst = 'summary', func = xml.get_element_text },
    pubDate = {
      dst = 'published_at',
      func = function(x)
        -- convert date to ts
        return xml.get_element_text(x)
      end,
    },
  }

  ---@return Post?
  return function()
    local ret = {}
    i = i + 1
    if not self._els[i] then return end
    while self._els[i].name ~= 'item' do
      i = i + 1
    end

    ret = xml.extract(value_mappings, self._els[i].el)

    return ret
  end
end

return {
  ['2.0'] = Rss20,
}
