-- IFTTTを使う

local m = {}

-- Maker Channel にリクエストを送信する
function m.maker(args)
	return http.request {
		url = 'https://maker.ifttt.com/trigger/'..args.event..'/with/key/'..args.key,
		method = 'POST',
		headers = {
			['Content-Type'] = 'application/json; charset=UTF-8',
		},
		data = json.stringify({
				value1 = args.value[1],
				value2 = args.value[2],
				value3 = args.value[3],
		}),
	}
end

return m
