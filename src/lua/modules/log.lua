local Module = {}

local function argtostring (...)
  local message = ''

  for _, arg in ipairs({...}) do
    message = message .. ' ' .. arg
  end

  return message
end

local function printstring (level, message)
  return ngx.log(level, message)
end

function Module.log (...)
  return Module.err(...)
end

function Module.err (...)
  return printstring(ngx.ERR, argtostring(...))
end

return Module
