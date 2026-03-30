local M = {}

--- get text values from list of elements by name
---@param wanted string[]
---@param els table[]
---@return table<string, string>
M.extract = function(wanted, els)
  local want = {}
  for _, k in ipairs(wanted) do
    want[k] = true
  end

  local ret = {}
  for _, e in ipairs(els) do
    if want[e.name] and e.kids[1] then ret[e.name] = e.kids[1].value end
  end

  return ret
end

--- remap keys of table according to map
---@param raw table<string, any>
---@param map table<string, string> source > dest
---@return table<string, any>
M.map_fields = function(raw, map)
  local out = {}
  for src, dst in pairs(map) do
    out[dst] = raw[src]
  end
  return out
end

return M
