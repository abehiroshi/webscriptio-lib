local hub = require 'hub'
local line = require 'line'

-- Line送信
hub.add_command('line', function(self, args)
	args.info = self.store.line.linebot_keys
	local response, data = line.send(args)
	local status = ''
	if response and response.statuscode ~= 200 then
		status = 'error'
	end
	return data, status
end)

return hub