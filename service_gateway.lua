-- サービスゲートウェイ

-- ログ初期化
local logger = (require 'logger').get('service_gateway')
local memory = require 'memory'
local line = require 'line'

local m = {}

local services = {
    line = {
        push = function(params, store)
            params.access_token = store.line.access_token
	        local response = line.send(params)
            if response.statuscode ~= 200 then
		        return 'error:'..response.statuscode
            else
                return 'ok'
	        end
        end
    }
}
 
function m:execute(method, params)
    local service = services[self.name]
    if not service then
        logger.info('service not found', self.name)
        return {}
    end

    if not service[method] then
        logger.info('method nor found', self.name, merhod)
        return {}
    end

    local store = memory.create(self.store_name or 'config'):dump()

    return service[method](params, store)
end

function m.create(args)
    return setmetatable(args or {}, {__index = m})
end

return m
