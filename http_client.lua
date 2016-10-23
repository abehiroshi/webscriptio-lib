-- HTTP Client

local logger = (require 'logger').get('http_client')

local m = {}

function m.request(params)
    logger.info('request start', params.url)
    logger.debug('request start', params)
    
    local response = http.request(params)
    
    logger.info('request end', response.statuscode)
    logger.debug('request end', response)
    
    return response
end

return m
