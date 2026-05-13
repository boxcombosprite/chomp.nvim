local xml = require 'chomp.util.xml'
local url = require 'chomp.util.url'

local Base = {}
Base.__index = Base

---@class Atom10
---@field _title string
---@field _updated string
---@field _els table<XmlElement>
---@field _entries_from integer
---@field _doc XmlDocument
local Atom10 = setmetatable({}, Base)
Atom10.__index = Atom10

---@protected
Atom10.find_feed_el = function(self)
  if not self._doc then
    vim.notify('tried parsing feed with uninitialized parser', 'error')
    return
  end
  for _, k in ipairs(self._doc.kids) do
    if k.name == 'feed' then return k end
  end
end

---@param doc XmlDocument
---@return Atom10
Atom10.new = function(doc)
  local self = setmetatable({ _doc = doc }, Atom10)

  local feedel = self:find_feed_el()
  if not feedel then error 'no <feed> element' end

  local channel_els = feedel.el
  local i = 1
  while channel_els[i] and channel_els[i].name ~= 'entry' do
    i = i + 1
  end

  local meta = xml.extract({
    title = { dst = '_title', func = xml.get_element_text },
    updated = { dst = '_updated', func = xml.get_element_text },
  }, { table.unpack(channel_els, 1, i - 1) })

  self = vim.tbl_extend('force', self, meta)
  self._entries_from = i
  self._els = channel_els

  return self
end

---@return string?
Atom10.get_title = function(self) return self._title end

---@return string?
Atom10.get_updated = function(self) return self._updated end

---@return fun(): Post?
Atom10.posts = function(self)
  local i = self._entries_from - 1

  local value_mappings = {
    title = { dst = 'title', func = xml.get_element_text },
    link = { dst = 'url', func = xml.get_element_text },
    id = { dst = 'guid', func = xml.get_element_text },
    summary = { dst = 'summary', func = xml.get_element_text },
    published = {
      dst = 'published_at',
      func = function(x)
        -- convert date to ts
        return xml.get_element_text(x)
      end,
    },
    updated = {
      dst = 'updated_at',
      func = function(x)
        -- convert
        return xml.get_element_text(x)
      end,
    },
  }

  ---@return Post?
  return function()
    local ret = {}
    i = i + 1
    if not self._els[i] then return end
    while self._els[i].name ~= 'entry' do
      i = i + 1
    end

    ret = xml.extract(value_mappings, self._els[i].el)

    return ret
  end
end

return {
  ['1.0'] = Atom10,
}
