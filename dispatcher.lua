-- Event dispatcher

local m = {}
local logger = function() end

local stringify = require 'stringify'
local memory = require 'memory'
local hub = require 'hub'
require 'hub_amazon'
require 'hub_irkit'
require 'hub_ifttt'
require 'hub_line'

local lustache = {
	render = function(self, str, args)
		return str
	end
}

-- hub登録：文字列を切り分け変換
hub.add_command('translate', function(self, args)
	local result = {text = args.text}
	for i,v in ipairs(args.patterns) do
		matched = {string.match(args.text, v.pattern)}
		if #matched > 0 then
			for j,s in ipairs(matched) do
				if v.keys and v.keys[j] then
					result[v.keys[j]] = s
				else
					result[j] = s
				end
			end

			self.context[v.name] = result
			return result, v.name
		end
	end

	return result, 'nomatch'
end)

-- hubのdefault関数作成
function hub_default(self, event)
	self.context[event.name] = event.result
	local status = (event.status and string.format(':%s', event.status)) or ''
	if status == ':' then status = '' end
	local key = event.name..status
    logger('event: '..key)

	local command = self._listeners[key]
	if command then
		local commands_text = lustache:render(
			stringify.encode(command),
			{self = self, event = event}
		)
		logger('commands: '..commands_text)
		local commands = json.parse(commands_text)
		if #commands > 0 then
			self:push(unpack(commands))
		else
			self:push(commands)
		end
    else
        logger('no command: '..key)
	end
end

-- ロガーを設定
function m.use_logger(_logger)
    logger = _logger
end

-- luatacheを使用する
function m.use_lustache(_lustache)
	lustache = _lustache
end

function m.create(name, self)
	self.context = self.context or {}
	self._listeners = self.listeners or {}
	local h = hub.create(name, self)
    h:on_default(hub_default)
	return h
end

return m
