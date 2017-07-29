-- HTTP Request入口

-- ログ初期化
local logger = (require 'logger').get('service')
local gateway = require 'service_gateway'

local m = {}

-- HTTP Requestを受信
function m:execute(request)
    logger.info('service start')
    logger.debug('request', request)
    if not request then return {} end

    local params = {}
    if type(request.query) == 'table' then
        params = request.query
    elseif request.body then
        local result, body = pcall(json.parse, request.body)
        if result and type(body) == 'table' then
            logger.trace('entry json.parse', body)
            params = body
        end
    end

    local ok, result = pcall(gateway.execute, params)
    if not ok then
        logger.error(result)
    end

    logger.info('service end')
    logger.debug('service', result)
    return result
end

function m.create(args)
    return setmetatable(args or {}, {__index = m})
end

return m