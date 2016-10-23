-- LINE Botを使う

local http_client = require 'http_client'
local stringify = require 'stringify'

local m = {}

local EventType = {
	single = '138311608800106203',
	multi  = '140177271400161403',
}

-- LINE Botがメッセージを送る
function m.message(channel, data)
    data.toChannel = '1383378250'

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
		local contentType
		if v.contentType then contentType = v.contentType
		elseif v.text then contentType = 1
		elseif v.imageUrl or v.originalContentUrl then contentType = 2
		elseif v.STKID then contentType = 8
		end
		if contentType then
			table.insert(messages, {
				contentType = contentType,
				text = stringify.encode(v.text),
				originalContentUrl = v.originalContentUrl or v.imageUrl,
				previewImageUrl = v.previewImageUrl or v.imageUrl,
				contentMetadata = {
					STKID = v.STKID,
					STKPKGID = v.STKPKGID,
					STKVER = v.STKVER,
				},
			})
		end
	end

	local to = args.to
	if type(to) == 'string' then
		to = {to}
	end

	return m.message(args.info, {
		eventType = EventType.multi,
		to = to,
		content = {
			messages = messages,
		}
	})
end

-- LINE Botがテキストメッセージを送る
function m.text(channel, indata)
	return m.message(channel, {
		eventType = EventType.single,
		to = indata.to,
		content = {
			toType = 1,
			contentType = 1,
			text = stringify.encode(indata.text),
		}
	})
end

-- LINE Botが画像を送る
function m.image(channel, indata)
	return m.message(channel, {
		eventType = EventType.single,
		to = indata.to,
		content = {
			toType = 1,
			contentType = 2,
			originalContentUrl = indata.originalContentUrl or indata.imageUrl,
			previewImageUrl = indata.previewImageUrl or indata.imageUrl,
		}
	})
end

-- LINE Botがスタンプを送る
function m.stamp(channel, indata)
	return m.message(channel, {
		eventType = EventType.single,
		to = indata.to,
		content = {
			toType = 1,
			contentType = 8,
			contentMetadata = {
				STKID = indata.STKID,
				STKPKGID = indata.STKPKGID,
				STKVER = indata.STKVER,
			}
		}
	})
end

-- LINE Botがリッチメッセージを送る
function m.rich(channel, indata)
	return m.message(channel, {
		eventType = EventType.single,
		to = indata.to,
		content = {
			toType = 1,
			contentType = 12,
			contentMetadata = {
				DOWNLOAD_URL = indata.DOWNLOAD_URL,
				SPEC_REV = 1,
				ALT_TEXT = indata.ALT_TEXT,
				MARKUP_JSON = indata.MARKUP_JSON,
			}
		}
	})
end

return m
