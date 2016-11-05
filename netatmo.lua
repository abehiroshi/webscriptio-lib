
local logger = (require 'logger').get('netatmo')
local http_client = require 'http_client'

local m = {}

function m:oauth_token(args)
    logger.info('oauth_token')
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
    logger.debug('oauth_token end', response)
    return response
end


function m.create(self)
    return setmetatable(self or {}, {__index = m})
end

return m
