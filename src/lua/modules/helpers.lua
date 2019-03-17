local log = require 'log'

local Module = {}

function Module.bail ()
  log.log('BAIL!')

  ngx.status = 444
  ngx.print('{"error":"not authorized"}')
  ngx.exit(444)
  return
end

function Module.client ()
  local redis = require 'resty.redis'
  local client = redis:new()
  local ok, _ = client:connect('redis', 6379)

  return ok, client
end


return Module
