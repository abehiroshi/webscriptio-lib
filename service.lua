-- HTTP Request入口

-- ログ初期化
local logger = (require 'logger').get('service')
local gateway = require 'service_gateway'

local m = {}

-- HTTP Requestを受信
function m:execute(request)
    logger.info('service start')
    logger.debug('service', request)

    local params = {}
    if request and request.body then
        local result, body = pcall(json.parse, request.body)
        if result and type(body) == 'table' then
            logger.trace('entry json.parse', body)
            params = body
        else if type(request.query) == 'table' then
            params = request.query
        end
    end

    local method = request.body.method
    local gateway = gateway.create()

    local ok, result = pcall(gateway:execute, gateway, method, params)
    if not ok then
        logger.error(result)
    end

    logger.info('service end')
    logger.debug('service', result)
    return result
end

function m.create(args){
    return setmetatable(args or {}, {__index = m})
}

return m