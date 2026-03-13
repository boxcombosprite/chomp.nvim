if vim.g.chomp_loaded then return end
vim.g.chomp_loaded = 1

vim.api.nvim_create_user_command('Chomp', function(opts)
  if #opts.args == 0 then
    print 'hello from chomp'
    return
  end

  print('arg: ', opts.args)
end, { desc = 'some description', nargs = '?' })

print(1)
-- vim: ts=2 sts=2 sw=2 et
