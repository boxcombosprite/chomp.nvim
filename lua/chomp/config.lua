local M = {}

---@class ChompSettings
local DEFAULT_SETTINGS = {
  data_dir = vim.fn.stdpath 'data' .. '/chomp',
  log_level = vim.log.levels.INFO,
  ui = {
    width = 0.4,
    height = 0.8,
    border = nil,
    keymaps = {
      refresh_all_feeds = 'R',
      refresh_selected_feed = 'r',
      add_new_feed = 'a',
      unsub_selected_feed = 'x',
      expand_posts = '<CR>',
      open_post = '<CR>',
      close_float = 'q',
    },
  },
  feeds = {},
  refresh_on_open = false,
  curl_flags = {},
  default_view = 'by_feed',
}

M._DEFAULT_SETTINGS = DEFAULT_SETTINGS
M.current = M._DEFAULT_SETTINGS

---@param opts ChompSettings
M.set = function(opts) M.current = vim.tbl_deep_extend('force', vim.deepcopy(M.current), opts) end

return M
