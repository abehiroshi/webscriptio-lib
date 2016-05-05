-- LINE Botを使う

local m = {}

local EventType = {
	single = '138311608800106203',
	multi  = '140177271400161403',
}

-- LINE Botがメッセージを送る
function m.message(channel, data)
    data.toChannel = '1383378250'

    return http.request {
	    url = 'https://trialbot-api.line.me/v1/events',
	    method = 'POST',
	    headers = {
	    	['Content-Type'] = 'application/json; charset=UTF-8',
	       	['X-Line-ChannelID'] = channel.id,
	    	['X-Line-ChannelSecret'] = channel.secret,
	    	['X-Line-Trusted-User-With-ACL'] = channel.mid,
	    },
	    data = json.stringify(data),
    }
end

-- LINE Botが複数メッセージを送る
function m.send(channel, indata)
	local messages = {}
	for i,v in ipairs(indata.messages) do
		local contentType
		if v.contentType then contentType = v.contentType
		elseif v.text then contentType = 1
		elseif v.originalContentUrl then contentType = 2
		elseif v.STKID then contentType = 8
		end
		table.insert(messages, {
			contentType = contentType,
			text = v.text,
			originalContentUrl = v.originalContentUrl or v.imageUrl,
			previewImageUrl = v.previewImageUrl or v.imageUrl,
			contentMetadata = {
				STKID = v.STKID,
				STKPKGID = v.STKPKGID,
				STKVER = v.STKVER,
			},
		})
	end
	
	return m.message(channel, {
		eventType = EventType.multi,
		to = indata.to,
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
			text = indata.text,
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
				SPEC_REV = indata.SPEC_REV,
				ALT_TEXT = indata.ALT_TEXT,
				MARKUP_JSON = indata.MARKUP_JSON,
			}
		}
	})
end

return m
