-- hubにコマンド登録

local m = {}

local hub = require 'hub'
setmetatable(m, {__index = hub})

-- コマンド
local command = {}

-- Amazon商品検索
local amazon = require 'amazon'
function command.amazon_itemsearch(self, args)
	local ret = amazon.itemsearch {
		info = self.amazon_info,
		params = {Keywords = args},
	}
	if ret and ret.Items then
	    ret.item1 = ret.Items[1]
	end
	local status
	if ret.error then
		status = 'error'
	end
	return ret, status
end

-- Line送信
local line = require 'line'
function command.line(self, args)
	args.info = self.line_info
	local response, data = line.send(args)
	local status
	if response.statuscode ~= 200 then
		status = 'error'
	end
	return data, status
end

-- IFTTT送信
local ifttt = require 'ifttt'
function command.ifttt_maker(self, args)
	local response = ifttt.maker {
		key = self.ifttt_maker_key,
		event = args.event,
		value = args.value,
	}
	local status
	if response.statuscode ~= 200 then
		status = 'error'
	end
	return response.content, status
end

-- hubにコマンドを登録する
function m.require(commands)
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
