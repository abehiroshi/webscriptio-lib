local hub = require 'hub'
local memory_google = require 'memory_google'

-- Line送信
hub.add_command('load_memory_google', function(self, args)
    local mg = memory_google.create(args.memoryname)
    local loaded = mg:load(args.sheetname)
	return loaded:dump()
end)

return hub