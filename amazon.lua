-- AmazonのAPIを使う

local m = {}

local lom = require 'lxp.lom'
local util = require 'util'

-- AmazonにHTTPリクエストを送信する
function m.request(info, params)
    params.AWSAccessKeyId = info.AWSAccessKeyId
    params.AssociateTag = info.AssociateTag
    params.Version = info.Version
    params.Timestamp = os.date("!%Y-%m-%dT%T.000Z")
    params.Signature = base64.encode(
        crypto.hmac(
            info.SecretAccessKey,
            (info.method.."\n"..
                info.endpoint.."\n"..
				info.uri.."\n"..
				util.toQuery(params)),
            crypto.sha256).digest())
    
    local response = http.request {
        url = info.protocol..'://'..info.endpoint..info.uri,
        params = params,
    }
    return lom.parse(response.content)
end

return m
