-- Event dispatcher

local m = {}

local template = require 'abehiroshi/webscriptio-lib/template'
local memory = require 'abehiroshi/webscriptio-lib/memory'
local hub = require 'abehiroshi/webscriptio-lib/hub_command'

function hub_default(self, event)
	self.context[event.name] = event.result
	local status = (event.status and string.format(':%s', event.status)) or ''
	if status == ':' then status = '' end
    self._logger('event: '..event.name..status)

	local command = assistant.data[event.name..status]
	if command then
		local commands = template.apply(command, {self = self,	event = event})
		if #commands > 0 then
			self:push(unpack(commands))
		else
			self:push(commands)
		end
    else
        self._logger('no command: '..event.name..status)
	end
end

function m:use_logger(logger)
    self._logger = logger
end

function m:use_luatache(lustache)
    template = template.use(lustache)
end

function m.create(name, hub_require, self)
    hub.require(hub_require)
    local h = hub.new(name, data)
    h:on_default(hub_default)

    self._logger = function() end
    self._hub = h
    self._memory = memory.create(name)
	return setmetatable(self, {__index = m})
end

return m
