local xml = require 'chomp.util.xml'
local url = require 'chomp.util.url'

local Base = {}
Base.__index = Base

---@class Atom10
---@field _title string
---@field _updated string
---@field _els table[]
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

  local meta = xml.extract({ 'title', 'updated' }, { table.unpack(channel_els, 1, i - 1) })
  self._title = meta.title
  self._updated = meta.updated
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
  local els = self._els

  return function()
    local ret = {}
    i = i + 1
    while els[i] and els[i].name ~= 'entry' do
      i = i + 1
    end
    if not els[i] then return nil end
    for _, v in ipairs(els[i].el) do
      if v.name == 'title' and v.kids[1] then
        ret.title = v.kids[1].value
      elseif v.name == 'link' and v.attr.href then
        ret.url = url.normalize(v.attr.href)
      elseif v.name == 'id' and v.kids[1] then
        ret.guid = v.kids[1].value
      elseif v.name == 'updated' and v.kids[1] then
        ret.updated_at = v.kids[1].value -- convert to timestamp or some shit
      elseif v.name == 'published' and v.kids[1] then
        ret.published_at = v.kids[1].value -- same
      elseif v.name == 'summary' and v.kids[1] then
        ret.summary = v.kids[1].value -- respect type attr and shit
      end
    end

    return ret
  end
end

return {
  ['1.0'] = Atom10,
}
