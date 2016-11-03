-- HTTP Client

local logger = (require 'logger').get('http_client')

local m = {}

function m.request(params)
    logger.info('request start', params.url)
    logger.trace('request start', params)

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
