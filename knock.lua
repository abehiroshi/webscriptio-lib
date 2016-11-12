-- サービスを叩く

local logger = (require 'logger').get('knock')
local memory = require 'memory'
local http_client = require 'http_client'

local m = {}

-- HTTP Requestを実行する
function m:request(request)
    logger.info('request', self)
    logger.debug(request)

    local knock = memory.create(self.memory_name)
    for i,v in ipairs(knock.data.requests or {}) do
        http_client.request(v)
    end
end

-- knockを作成する
function m.create(args)
    return setmetatable(args or {}, {__index = m})
end

return m
