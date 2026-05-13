local M = {}

---@class XmlDocument
---@field type 'document'
---@field name '#doc'
---@field kids table<XmlProcessingInstruction|XmlElement|XmlCommentNode>
---@field root XmlElement

---@class XmlAttribute

---@class XmlTextNode

---@class XmlCommentNode

---@class XmlProcessingInstruction

---@class XmlElement
---@field type 'element'
---@field name string
---@field nsURI string
---@field nsPrefix string
---@field attr table<string|integer, XmlAttribute|XmlAttribute[]> indexed by both name (string->attr) and index (int->table of attrs)
---@field kids table<XmlElement|XmlCommentNode|XmlTextNode|XmlProcessingInstruction>
---@field el table<XmlElement>
---@field parent XmlElement | XmlDocument

---@class XmlMapping
---@field dst string destination key in output table
---@field func fun(e: table): string?

---@alias XmlMappingTable table<string, XmlMapping>

---@param e XmlElement
---@return string?
M.get_element_text = function(e)
  if e.kids[1] then return e.kids[1].value end
end

---@param e XmlElement
---@return string?
M.get_element_attr = function(e) end

---@param mappings XmlMappingTable
---@param els table[]
---@return table<string, string?>
M.extract = function(mappings, els)
  local ret = {}

  for _, v in ipairs(els) do
    if mappings[v.name] then ret[mappings[v.name].dst] = mappings[v.name].func(v) end
  end

  return ret
end

return M
