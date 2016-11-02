local hub = require 'hub'
local memory_google = require 'memory_google'

-- memoryをgoogle spreadsheet から読み込む
hub.add_command('load_memory_google', function(self, args)
    local mg = memory_google.create(args.memoryname, self.store.google)
    local loaded = mg:load(args.sheetname)
	return loaded:dump(), ''
end)

return hub