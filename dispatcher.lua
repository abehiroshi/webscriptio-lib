-- Event dispatcher

local m = {}
local logger = function() end

local template = require 'template'
local memory = require 'memory'
local hub = require 'hub_command'
require 'hub_amazon'

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

function m.hub_require(...)
	hub.require(...)
end

function m.create(name, self)
	local h = hub.new(name, self)
    h:on_default(hub_default(name))
	return h
end

return m
