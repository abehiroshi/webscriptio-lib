local hub = require 'hub'
local ifttt = require 'ifttt'

-- IFTTT送信
hub.add_command('ifttt_maker', function(self, args)
	local response = ifttt.maker {
		key = self.ifttt_maker_key,
		event = args.event,
		value = args.value,
	}
	local status = ''
	if response.statuscode ~= 200 then
		status = 'error'
	end
	return response.content, status
end)

return hub