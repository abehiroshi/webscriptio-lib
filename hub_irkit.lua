local hub = require 'hub'
local irkit = require 'irkit'

-- IRKit受信
hub.add_command('irkit_receive', function(self, args)
	local ir = irkit.create(self.irkit_info)
	local response = ir:receive()
	local status = ''
	if response.statuscode ~= 200 then
		status = 'error'
	end
	if self.context and args and args.name then
		self.context.irkit_receive = {}
		self.context.irkit_receive[args.name] = response.message
	end
	return response, status
end)

-- IRKit送信
hub.add_command('irkit_send', function(self, args)
	local ir = irkit.create(self.irkit_info)
	local response = ir:send(args.message)
	local status = ''
	if response.statuscode ~= 200 then
		status = 'error'
	end
	return response, status
end)

return hub