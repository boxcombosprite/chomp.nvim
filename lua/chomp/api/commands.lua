vim.api.nvim_create_user_command('Chomp', function(opts)
  if #opts.args == 0 then
    local win = require('chomp.ui').new_win {}
    win.open()
    return
  end

  print('arg: ', opts.args)
end, { desc = 'some description', nargs = '?' })
