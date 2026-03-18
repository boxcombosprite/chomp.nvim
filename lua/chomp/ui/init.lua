local config = require 'chomp.config'
local state = require 'chomp.state'

local M = {}

---@class chomp.Window
---@field open function
---@field close function

---@class chomp.FloatConfig
---@field win_config vim.api.keyset.win_config
---@field win_opts table the windowlocal options
---@field buf_opts table the buflocal options

---@param opts table
---@return chomp.FloatConfig
local create_float_config = function(opts)
  local options = opts or {}
  local width = options.width or math.floor(vim.o.columns * config.current.ui.width)
  local height = options.height or math.floor(vim.o.lines * config.current.ui.height)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  ---@type vim.api.keyset.win_config
  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = config.current.ui.border or vim.g.winborder,
    zindex = 45,
  }

  local win_opts = {
    number = false,
    relativenumber = false,
    wrap = false,
    spell = false,
    foldenable = false,
    signcolumn = 'no',
    colorcolumn = '',
    cursorline = true,
  }

  local buf_opts = {
    modifiable = false,
    swapfile = false,
    textwidth = 0,
    buftype = 'nofile',
    bufhidden = 'wipe',
    buflisted = false,
    filetype = 'chomp',
  }

  return {
    win_config = win_config,
    win_opts = win_opts,
    buf_opts = buf_opts,
  }
end

---@param opts chomp.FloatConfig
---@return table
local spawn_float = function(opts)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, config.win_config)

  for key, value in pairs(opts.win_opts) do
    vim.api.nvim_set_option_value(key, value, { win = win, scope = 'local' })
  end

  for key, value in pairs(opts.buf_opts) do
    vim.api.nvim_set_option_value(key, value, { buf = buf, scope = 'local' })
  end

  return { buf = buf, win = win }
end

---@param opts table
---@return chomp.Window
M.new_win = function(opts)
  local options = opts or {}
  local float

  local close = function()
    if float and vim.api.nvim_win_is_valid(float.win) then pcall(vim.api.nvim_win_close, float.win, true) end
  end

  local open = function()
    local float_config = create_float_config(options)
    float = spawn_float(float_config)
    vim.keymap.set('n', 'q', close, { buffer = float.buf })

    vim.api.nvim_create_autocmd('VimResized', {
      group = vim.api.nvim_create_augroup('chomp-resized', {}),
      callback = function()
        if not vim.api.nvim_win_is_valid(float.win) then return end

        --dirty yes
        local updated = create_float_config {}
        vim.api.nvim_win_set_config(float.win, updated.win_config)
      end,
    })

    vim.api.nvim_create_autocmd('BufLeave', {
      buffer = float.buf,
      callback = close,
    })
    --local namespace = vim.api.nvim_create_namespace("ns")
  end

  return {
    close = close,
    open = open,

    state = function()
      local mutate_state, get_state
      return mutate_state, get_state
    end,

    draw = function() end,
  }
end

-- TODO: keymaps for categories, refresh, refresh all, open in og buffer

-- nvim_create_namespace()

-- drawing:
-- nvim_buf_clear_namespace()
-- nvim_buf_set_option() (set modifiable to true for just the update)
-- nvim_buf_set_lines()

return M
