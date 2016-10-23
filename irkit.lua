-- IRKitを使う

local http_client = require 'http_client'
local stringify = require 'stringify'

local m = {}

-- IRKit Internet HTTP APIにGET messagesを送信する
function m:receive(clear)
	local params = {clientkey = self.clientkey}
	if clear == true then
		params.clear = '1'
	end

	local response = http_client.request {
		url = "https://api.getirkit.com/1/messages",
		method = "GET",
		params = params,
	}

	if #response.content > 0 then
		response.message = string.gsub(json.stringify(json.parse(response.content).message), ' ', '')
	end
	return response
end

-- IRKit Internet HTTP APIにPOST messagesを送信する
function m:send(message)
	return http_client.request {
		url = "https://api.getirkit.com/1/messages",
		method = "POST",
		data = {
			clientkey = self.clientkey,
			deviceid = self.deviceid,
			message = stringify.encode(message),
		},
	}
end

function m.create(self)
	return setmetatable(self, {__index = m})
end

return m
