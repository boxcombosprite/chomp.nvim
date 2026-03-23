local util = require 'chomp.util'
--assert curl

local M = {}

M.head = function(url, callback)
  vim.system({ 'curl', '-L', '-s', '-I', util.url.normalize(url) }, { text = true }, function(obj)
    if obj.code ~= 0 then
      --notify
      return
    end
    local res = {}
    --parse and make table of headers
    callback(res)
  end)
end

M.get = function(url, callback)
  vim.system({ 'curl', '-L', '-s', '-I', util.url.normalize(url) }, { text = true }, function(obj)
    if obj.code ~= 0 then return end
    local res = {}
    --send string blob to callback
    callback(res)
  end)
end

return M
