-- HTTP Client

local logger = (require 'logger').get('http_client')
local stringify = require 'stringify'

local m = {}

function m.request(params)
    logger.info('request start', params.url)
    logger.trace('request start', params)

    if params and params.headers then
        local content_type = params.headers['Content-Type']
        if type(content_type) == 'string' and content_type:find('^application/json') then
            logger.trace('Content-Type:', content_type)
            params.data = stringify.encode(params.data)
        end
    end
    local response = http.request(params)

    if response then
        logger.info('request end', response.statuscode)
        logger.trace('request end', response)
    else
        logger.info('request end')
    end

    return response
end

return m
