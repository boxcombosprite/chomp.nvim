local M = {}

vim.api.nvim_create_user_command('Chomp', function(opts)
  if #opts.args == 0 then
    require('chomp.ui').open()
    return
  end

  print('arg: ', opts.args)
end, { desc = 'some description', nargs = '?' })

return M
