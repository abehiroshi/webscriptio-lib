local hub = require 'hub'
local line = require 'line'

-- Line送信
hub.add_command('line', function(self, args)
	args.access_token = self.store.line.access_token
	local response, data = line.send(args)
	local status = ''
	if response and response.statuscode ~= 200 then
		status = 'error'
	end
	return data, status
end)

return hub