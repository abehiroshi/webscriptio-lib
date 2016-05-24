-- hubにコマンド登録

local m = {}

local hub = require 'hub'
local amazon = require 'amazon'
local line = require 'line'

-- コマンド
local command = {}

-- Amazon商品検索
function command.amazon_itemsearch(self, args)
	local ret = amazon.itemsearch {
		info = self.amazon_info,
		params = {Keywords = args},
	}
	return ret, ret.error
end

-- Line送信
function command.line(self, args)
	args.info = self.line_info
	line.send(args)
end

-- hubにコマンドを登録する
function m.add(commands)
    if type(commands) == 'string' then
        commands = {commands}
    end
    for i,v in ipairs(commands) do
        if command[v] then
            hub.add_command(v, command[v])
        end
    end
end

return m
