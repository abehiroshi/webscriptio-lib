-- サービスゲートウェイ

-- ログ初期化
local logger = (require 'logger').get('service_gateway')
local memory = require 'memory'
local line = require 'line'

local m = {}

local services = {}

function services.line_push(params, store)
    params.access_token = params.access_token or store.line.access_token
	local response = line.send(params)
    if response.statuscode ~= 200 then
		return {result = 'error', statuscode = response.statuscode}
    else
        return {result = 'ok'}
	end
end
 
function m:execute(params)
    local service = services[params.service_method]
    if not service then
        logger.info('service is not found', params.service_method)
        return {result = 'service is not found'}
    end

    local store = memory.create(self.store_name or 'config'):dump()

    return service(params, store)
end

function m.create(args)
    return setmetatable(args or {}, {__index = m})
end

return m
