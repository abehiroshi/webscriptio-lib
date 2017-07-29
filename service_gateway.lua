-- サービスゲートウェイ

-- ログ初期化
local logger = (require 'logger').get('service_gateway')
local memory = require 'memory'
local line = require 'line'

local m = {}

local services = {}

function services.line_push(params, store)
    params.access_token = params.access_token or store.line.access_token
    if not params.to and not params.reply_token then
        params.to = store.line.my_mid
    end
	local response = line.send(params)
    if response.statuscode ~= 200 then
		return {result = 'error', statuscode = response.statuscode}
    else
        return {result = 'ok'}
	end
end
 
function m.execute(params)
    logger.debug('params', params)
    local service = services[params.service_method]
    if not service then
        logger.info('service is not found', params.service_method)
        return {result = 'service is not found'}
    end

    local store = memory.create(params.store_name or 'config'):dump()

    return service(params, store)
end

return m
