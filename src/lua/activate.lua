local log = require 'log'
local helpers = require 'helpers'

local ip = ngx.var.remote_addr
local blacklist = ngx.var.blacklist == '1'
local localnet = ngx.var.localnet == '1'
local allowed_country = ngx.var.allowed_country == '1'

if blacklist or not allowed_country and not localnet then
  log.err('bail on first ', ip, blacklist, localnet, allowed_country)
  helpers.bail()
  return
end

-- if connection coumes from local address, do nothing!
if localnet then
  return
end

local c_ok, client = helpers.client()
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
