local hub = require 'hub'
local irkit = require 'irkit'

-- IRKit受信
hub.add_command('irkit_receive', function(self, args)
	local ir = irkit.create(self.irkit)
	local response = ir:receive()
	local status = ''
	if response.statuscode ~= 200 then
		status = 'error'
	end
	if self.context and args and args.name then
		self.context.irkit = {}
		self.context.irkit[name] = response.message
	end
	return response.message, status
end)

-- IRKit送信
hub.add_command('irkit_send', function(self, args)
	local ir = irkit.create(self.irkit)
	local response = ir:send(args.message)
	local status = ''
	if response.statuscode ~= 200 then
		status = 'error'
	end
	return response.content, status
end)

return hub