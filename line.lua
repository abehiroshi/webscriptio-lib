-- LINE Botを使う

local m = {}

-- LINE Botがメッセージを送る
function m.message(channel, data)
    data.toChannel = '1383378250'
    data.eventType = '138311608800106203'

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

-- LINE Botがテキストメッセージを送る
function m.text(channel, indata)
	return m.message(channel, {
		to = indata.to,
		content = {
			toType = 1,
			contentType = 1,
			text = indata.text,
		}
	})
end

-- LINE Botが画像を送る
function m.text(channel, indata)
	return m.message(channel, {
		to = indata.to,
		content = {
			toType = 1,
			contentType = 2,
			originalContentUrl = indata.originalContentUrl or indata.imageUrl
			previewImageUrl = indata.previewImageUrl or indata.imageUrl
		}
	})
end

-- LINE Botがスタンプを送る
function m.stamp(channel, indata)
	return m.message(channel, {
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

return m
