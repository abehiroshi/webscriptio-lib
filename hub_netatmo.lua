local hub = require 'hub'
local netatmo = require 'netatmo'

hub.add_command('netatmo_get', function(self, args)
    local n = netatmo.create(self.store.netatmo)
    local response = n:get(args)
	local status = ''
	if response and response.statuscode ~= 200 then
		status = 'error'
	end
    return response.content, status
end)

return hub