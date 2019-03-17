local cjson = require 'cjson'
local log = require 'log'
local helpers = require 'helpers'

local c_ok, client = helpers.client()

if not c_ok then
  log.err('could not get client')
  return
end

local s = ngx.var.lua_status
local uuid = ngx.var.lua_uuid
local status = ''

log.log('uuid?', uuid, ', s?', s)

if s == '1' then
  status = 'accept'
elseif s == '0' then
  status = 'reject'
end

if not uuid then
  log.log('missing uuid')
  ngx.say('break here')
  return
end

local ip, g_err = client:get('allow:' .. uuid)
if g_err then
  log.err('failed to query', g_err)
  return
end

if (ip == ngx.null) then
  log.err('missing ip')
  return
end

local id = 'usr:' .. ip
local changed = false

if not (status == '') then
  client:hmset(id, 'status', status)
  client:expire(id, 86400)
  changed = true
else
  local res, err = client:hmget(
    id, 'ip', 'org', 'city', 'region', 'base', 'allow', 'deny', 'status', 'uuid'
  )

  if err then
    log.err('failed to get key: ', err)
    return
  elseif res == ngx.null then
    log.log('no response')
    return
  end

  log.log(cjson.encode(res))

  ngx.status = ngx.HTTP_OK
  ngx.say(cjson.encode({
    ['ip'] = res[1],
    ['org'] = res[2],
    ['city'] = res[3],
    ['region'] = res[4],
    ['base'] = res[5],
    ['allow'] = res[6],
    ['deny'] = res[7],
    ['status'] = res[8],
    ['uuid'] = res[9]
  }))
  ngx.exit(ngx.HTTP_OK)
  return
end

ngx.status = ngx.HTTP_OK
ngx.say('{"uuid":"' .. uuid .. '","status":"'.. status .. '","changed":' .. (changed and 'true' or 'false') .. '}')
ngx.exit(ngx.HTTP_OK)
