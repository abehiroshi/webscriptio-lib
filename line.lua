-- LINE Botを使う

local http_client = require 'http_client'
local stringify = require 'stringify'

local m = {}

-- LINE Botがメッセージを送る
function m.message(channel, data)
    return http_client.request {
    	url = 'https://api.line.me/v2/bot/message/push',
	    method = 'POST',
	    headers = {
	    	['Content-Type'] = 'application/json; charset=UTF-8',
	    	['Authorization'] = 'Bearer '..channel.access_token,
	    },
	    data = stringify.encode(data),
    }, data
end

-- LINE Botが複数メッセージを送る
function m.send(args)
	local messages = {}
	for i,v in ipairs(args.messages or {args}) do
		local type = 'text'
		if v.imageUrl or v.originalContentUrl then
            type ='image'
		elseif v.stickerId then
            type = 'sticker'
		end
		table.insert(messages, {
			type = type,
			text = stringify.encode(v.text),
			originalContentUrl = v.originalContentUrl or v.imageUrl,
			previewImageUrl = v.previewImageUrl or v.imageUrl,
			stickerId = v.stickerId,
		    packageId = v.packageId,
		})
	end

	return m.message(args.info, {
		to = args.to,
		messages = messages,
	})
end

-- LINE Botがテキストメッセージを送る
function m.text(channel, indata)
	return m.message(channel, {
		to = indata.to,
        type = 'text',
		text = stringify.encode(indata.text),
	})
end

-- LINE Botが画像を送る
function m.image(channel, indata)
	return m.message(channel, {
		to = indata.to,
        type = 'image',
		originalContentUrl = indata.originalContentUrl or indata.imageUrl,
		previewImageUrl = indata.previewImageUrl or indata.imageUrl,
	})
end

-- LINE Botがスタンプを送る
function m.stamp(channel, indata)
	return m.message(channel, {
		to = indata.to,
        type = 'sticker',
		stickerId = indata.stickerId,
	    packageId = indata.packageId,
	})
end

return m
