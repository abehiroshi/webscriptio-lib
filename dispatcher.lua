-- Event dispatcher

local m = {}
local logger = function() end

local util = require 'util'
local stringify = require 'stringify'
local memory = require 'memory'
local google = require 'google'
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

-- hub登録：memoryに登録
hub.add_command('memory', function(self, args)
	logger('memory: start '..stringify.encode(args))
	local mem = memory.create(args.memory_name)
	logger('memory: create')
	mem.data[args.name] = args.value
	logger('memory: set')
	if args.google and args.google.sheetname then
		logger('memory: google start')
		local g = google.create(self.google_info.keys, true)
		local sheet = g:spreadsheet(self.google_info.spreadsheetid.webscript)
		sheet:save_ssml(args.google.sheetname, mem:dump())
		logger('memory: google end')
	end
	logger('memory: end')
end)

-- hub_default内部関数：テンプレートを展開する
function command_convert(commands, args)
	return util.table_convert(commands, function(value)
		if type(value) == 'string' then
			return lustache:render(value, params)
		else
			return value
		end
	end)
end

-- hubのdefault関数作成
function hub_default(self, event)
	self.context[event.name] = event.result
	local status = (event.status and string.format(':%s', event.status)) or ''
	if status == ':' then status = '' end
	local key = event.name..status
    logger('event: '..key)

	local command = self._listeners[key]
	if command then
		command = util.table_convert(command, function(value)
			if type(value) == 'string' then
				return lustache:render(value, {self = self, event = event})
			else
				return value
			end
		end)
		logger('command: '..stringify(command))
		if #command > 0 then
			self:push(unpack(command))
		else
			self:push(command)
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
