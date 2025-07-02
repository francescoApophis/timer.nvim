local timer = require('timer')
local api = vim.api

api.nvim_create_user_command('TimerSet', function(args)
  timer.set(args.args)
end, {})

api.nvim_create_user_command('TimerKill', function(args)
  timer.kill()
end, {})
