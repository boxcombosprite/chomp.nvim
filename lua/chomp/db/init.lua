local config = require 'chomp.config'

local M = {}

local path = config.current.data_dir .. '/feeds.lua'

M.save = function(data)
  local tmp_path = path .. '.tmp'
  local f = io.open(tmp_path, 'w')
  if not f then return end
  f:write('return ' .. vim.inspect(data))
  f:close()

  os.rename(tmp_path, path)
end

M.load = function()
  local ok, res = pcall(dofile, path)
  if ok and res then
    return res
  else
    --log
    return nil
  end
end

return M
