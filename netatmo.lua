
local logger = (require 'logger').get('netatmo')
local http_client = require 'http_client'

local m = {}

function m:auth(args)
    logger.info('auth')
    logger.debug(args)
    local response = http_client.request {
        url = 'https://api.netatmo.com/oauth2/token',
        method = 'POST',
        data = {
            grant_type = 'password',
            client_id = args.client_id,
            client_secret = args.client_secret,
            username = args.username,
            password = args.password,
        },
    }
    logger.debug('auth end', response)
    return response
end

function m:refresh(args)
    logger.info('refresh')
    logger.debug(args)
    local response = http_client.request {
        url = 'https://api.netatmo.com/oauth2/token',
        method = 'POST',
        data = {
            grant_type = 'refresh_token',
            client_id = args.client_id,
            client_secret = args.client_secret,
            refresh_token = args.refresh_token,
        },
    }
    logger.debug('refresh end', response)
    return response
end

function m.create(self)
    return setmetatable(self or {}, {__index = m})
end

return m
