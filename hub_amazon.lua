local hub = require 'hub'
local amazon = require 'amazon'

-- Amazon商品検索
hub.add_command('amazon_itemsearch', function(self, args)
	local ret = amazon.itemsearch {
		info = self.amazon_info,
		params = {Keywords = args},
	}
	if ret and ret.Items then
	    ret.item1 = ret.Items[1]
	end
	local status = ''
	if ret.error then
		status = 'error'
	end
	return ret, status
end)

return hub