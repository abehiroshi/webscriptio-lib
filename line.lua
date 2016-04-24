local m = {}

function m.message(channel, data)
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

return m