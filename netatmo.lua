
local logger = (require 'logger').get('netatmo')
local http_client = require 'http_client'

local m = {}

function m:auth(args)
    logger.info('auth')
    logger.debug('get args', args)
    logger.debug('get self', self)
    args = setmetatable(args or {}, {__index = self})

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
    logger.debug('get args', args)
    logger.debug('get self', self)
    args = setmetatable(args or {}, {__index = self})

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

function m:get(args)
    logger.info('get')
    logger.debug('get args', args)
    logger.debug('get self', self)
    args = setmetatable(args or {}, {__index = self})

    local response = http_client.request {
        url = 'https://api.netatmo.com/api/getstationsdata',
        method = 'POST',
        data = {
            access_token = args.access_token,
            device_id = args.device_id,
            get_favorites = args.get_favorites,
        },
    }
    logger.debug('get end', response)
    return response
end

function m.create(self)
    return setmetatable(self or {}, {__index = m})
end

return m
