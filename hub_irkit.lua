local hub = require 'hub'
local irkit = require 'irkit'

-- IRKit受信
hub.add_command('irkit_receive', function(self, args)
	local ir = irkit.create(self.store.irkit)
	local response = ir:receive(args.clear == 1)
	local status = ''
	if response.statuscode ~= 200 then
		status = 'error'
	end
	return response.content, status
end)

-- IRKit送信
hub.add_command('irkit_send', function(self, args)
	local ir = irkit.create(self.store.irkit)
	local response = ir:send(json.parse(args.message))
	local status = ''
	if response.statuscode ~= 200 then
		status = 'error'
	end
	return response, status
end)

return hub