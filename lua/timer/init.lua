local uv = vim.loop
local api = vim.api
local vi = vim.inspect
local fmt = string.format

local M = {}


local TIMER = nil
local timer_on = false
local winh, winw = vim.fn.winheight(0), vim.fn.winwidth(0)
local bufnr, winnr = -1, -1
local win_config = {
  relative = "win", win = vim.fn.winnr(),
  anchor = "SE", width = 8, height = 1,
  row = winh, col = winw, focusable = false,
  style = "minimal", border = "rounded",
  zindex = 1000,
}

local toggle_buf_and_win = function(maybe_open)
  if maybe_open then
    bufnr = api.nvim_create_buf(false, true)
    winnr = api.nvim_open_win(bufnr, false, win_config)
  else
    vim.schedule(function()
      api.nvim_win_close(winnr, true)
      api.nvim_buf_delete(bufnr, {force = true})
    end)
  end
end


local buf_write = function(what)
  assert(type(what) == 'string', fmt("expected 'string', got '%s'", type(what)))
  vim.schedule(function() 
    api.nvim_buf_set_lines(bufnr, 0, 1, false, {what})
  end)
end



M.set = function(time)
  assert(type(time) == 'string', fmt("expected 'string', got '%s'", type(time)))
  if timer_on then return end

  timer_on = true
  local iter = time:gmatch('%d+')
  local hours, mins, secs = tonumber(iter()), tonumber(iter()), tonumber(iter())
  local tot_secs = hours * 3600 + mins * 60 + secs
  TIMER = uv.new_timer()
  toggle_buf_and_win(true)

  local x = 1 / 3600
  local y = 1 / 60

  TIMER:start(0, 1000, function()
    buf_write(fmt("%02d:%02d:%02d", tot_secs * x, (tot_secs % 3600) * y, tot_secs % 60))
    tot_secs = tot_secs - 1
    if tot_secs <= -1 then
      buf_write("OVER")
      if tot_secs <= -5 then
        toggle_buf_and_win(false)
        TIMER:stop()
        timer_on = false
      end
    end
  end)
end

M.kill = function()
  if not timer_on then
    vim.notify("Timer: no timer has been set, nothing to kill",  vim.log.levels.ERROR)
    return
  end
  toggle_buf_and_win(false)
  TIMER:stop()
  TIMER = nil
  timer_on = false
end



return M
