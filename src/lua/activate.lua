local log = require 'log'
local helpers = require 'helpers'

local c_ok, client = helpers.client()
local ip = ngx.var.remote_addr

if not c_ok then
  log.err('could not get client')
  helpers.bail()
  return
end

local p_ok, _ = client:publish('usr', ip)
if not p_ok then
  log.err('failed to publish:', ip)
  helpers.bail()
  return
end

local redis_id = 'usr:' .. ip
local allowed = false
local n = 0
while n < 120 do
  local res, q_err = client:hmget(redis_id, 'status')

  if q_err then
    log.err('failed to query:', q_err)
    break
  end

  local status = res[1]
  if not (status == ngx.null) and not (status == '') then
    log.err('status', status)
    allowed = status == 'accept'
    break
  end

  ngx.sleep(1)
  n = n + 1
end

if not allowed then
  helpers.bail()
  return
end

return
