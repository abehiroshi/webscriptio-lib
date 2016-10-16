-- IRKitを使う

local logger = (require 'logger').get('irkit')
local stringify = require 'stringify'

local m = {}

-- IRKit Internet HTTP APIにGET messagesを送信する
function m:receive(clear)
	local params = {clientkey = self.clientkey}
	if clear == true then
		params.clear = '1'
	end

	local request {
		url = "https://api.getirkit.com/1/messages",
		method = "GET",
		params = params,
	}
	logger.info('receive', request)
	local response = http.request(request)
	logger.info('receive', response)

	if #response.content > 0 then
		response.message = string.gsub(json.stringify(json.parse(response.content).message), ' ', '')
	end
	return response
end

-- IRKit Internet HTTP APIにPOST messagesを送信する
function m:send(message)
	local request = {
		url = "https://api.getirkit.com/1/messages",
		method = "POST",
		data = {
			clientkey = self.clientkey,
			deviceid = self.deviceid,
			message = stringify.encode(message),
		},
	}
	logger.info('send', request)
	local response = http.request(request)
	logger.info('send', response)
	return response
end

function m.create(self)
	return setmetatable(self, {__index = m})
end

return m
