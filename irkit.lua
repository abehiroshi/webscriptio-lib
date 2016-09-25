-- IRKitを使う

local m = {}

local stringify = require 'stringify'

-- IRKit Internet HTTP APIにGET messagesを送信する
function m:receive(clear)
	local params = {clientkey = self.clientkey}
	if clear == true then
		params.clear = '1'
	end

	local response = http.request {
		url = "https://api.getirkit.com/1/messages",
		method = "GET",
		params = params,
	}
	if #response.content > 0 then
		response.message = json.stringify(json.parse(response.content).message)
	end
	return response
end

-- IRKit Internet HTTP APIにPOST messagesを送信する
function m:send(message)
	local response = http.request {
		url = "https://api.getirkit.com/1/messages",
		method = "POST",
		data = {
			clientkey = self.clientkey,
			deviceid = self.deviceid,
			message = stringify.encode(message),
		},
	}
	return response
end

function m.create(self)
	return setmetatable(self, {__index = m})
end

return m
