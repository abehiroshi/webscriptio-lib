-- AmazonのAPIを使う

local m = {}

local util = require 'util'

-- AmazonにHTTPリクエストを送信する
function m.request(args)
    local info = args.info
    local params = args.params
    
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
    
    return http.request {
        url = info.protocol..'://'..info.endpoint..info.uri,
        params = params,
    }
end

return m
