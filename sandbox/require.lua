local line = require 'abehiroshi/webscriptio-lib/line'

local m = {}

function m.message()
    line.message(json.parse(storage.linebot_keys or {}), {
    		to = {storage.linebot_my_mid},
    		content = {
    			contentType = 1,
    			toType = 1,
    			text = 'できた？',
    		},
    })
end

return m
