-- Event dispatcher

local m = {}
local logger = function() end

local template = require 'template'
local memory = require 'memory'
local hub = require 'hub'
require 'hub_amazon'
require 'hub_line'
require 'hub_ifttt'

-- hub登録：文字列を切り分け変換
hub.add_command('translate', function(self, args)
	local result = {text = args.text}
	for i,v in ipairs(args.patterns) do
		matched = {string.match(args.text, v.pattern)}
		if #matched > 0 then
			for j,s in ipairs(matched) do
				if v.names and v.keys[j] then
					result[v.keys[j]] = s
				else
					result[j] = s
				end
			end

			return result, v.name
		end
	end

	return result, 'nomatch'
end)

-- hubのdefault関数作成
function hub_default(memory_name)
	local mem = memory.create(memory_name)

	return function(self, event)
		self.context[event.name] = event.result
		local status = (event.status and string.format(':%s', event.status)) or ''
		if status == ':' then status = '' end
		local key = event.name..status
	    logger('event: '..key)

		local command = mem.data[key]
		if command then
			local commands = template.apply(command, {self = self,	event = event})
			if #commands > 0 then
				self:push(unpack(commands))
			else
				self:push(commands)
			end
	    else
	        logger('no command: '..key)
		end
	end
end

-- ロガーを設定
function m.use_logger(_logger)
    logger = _logger
end

-- luatacheを使用する
function m.use_luatache(...)
    template = template.use(...)
end

function m.create(name, self)
	local h = hub.new(name, self)
    h:on_default(hub_default(name))
	return h
end

return m
