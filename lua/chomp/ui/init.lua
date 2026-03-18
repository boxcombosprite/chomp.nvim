local M = {}

local create_float_config = function(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.4)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

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
    border = opts.border or 'none',
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

local spawn_float = function(config)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, config.win_config)

  for key, value in pairs(config.win_opts) do
    vim.api.nvim_set_option_value(key, value, { win = win, scope = 'local' })
  end

  for key, value in pairs(config.buf_opts) do
    vim.api.nvim_set_option_value(key, value, { buf = buf, scope = 'local' })
  end

  return { buf = buf, win = win }
end

M.open = function()
  local float_config = create_float_config {}
  local float = spawn_float(float_config)
  vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(float.win, true) end, { buffer = float.buf })

  vim.api.nvim_create_autocmd('VimResized', {
    group = vim.api.nvim_create_augroup('chomp-resized', {}),
    callback = function()
      if not vim.api.nvim_win_is_valid(float.win) then return end

      local updated = create_float_config()
      vim.api.nvim_win_set_config(float.win, updated.win_config)
      --recalc contents
    end,
  })
  --local namespace = vim.api.nvim_create_namespace("ns")
end

-- nvim_create_namespace()

-- drawing:
-- nvim_buf_clear_namespace()
-- nvim_buf_set_option() (set modifiable to true for just the update)
-- nvim_buf_set_lines()

return M
