-- Event dispatcher

local logger = (require 'logger').get('dispatcher')
local util = require 'util'
local stringify = require 'stringify'
local memory = require 'memory'
local google = require 'google'
local filling = require 'filling'
local history = require 'history'
local http_client = require 'http_client'
local hub = require 'hub'
require 'hub_amazon'
require 'hub_irkit'
require 'hub_ifttt'
require 'hub_line'
require 'hub_memory_google'
require 'hub_netatmo'

local m = {}

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

            local status = v.status or result.status or ''
			self.context[status] = result
			return result, status
		end
	end

	return result, 'nomatch'
end)

-- hub登録：式を評価
hub.add_command('expression', function(self, args)
    for i,v in ipairs(args.expressions) do
        local num = tonumber(args.values[v.apply.var])
        local comp = v.apply['>']
        if comp and num > tonumber(comp) then
            return args.values, v.status
        end
        comp = v.apply['<']
        if comp and num < tonumber(comp) then
            return args.values, v.status
        end
        comp = v.apply['<=']
        if comp and num <= tonumber(comp) then
            return args.values, v.status
        end
        comp = v.apply['>=']
        if comp and num >= tonumber(comp) then
            return args.values, v.status
        end
    end
    return args.values, ''
end)

-- hub登録：memoryに登録
hub.add_command('memory', function(self, args)
	local mem = memory.create(args.memory_name)
	if args.value ~= nil then
		mem.data[args.name] = args.value
	end
	if args.google and args.google.sheetname then
		local g = google.create(self.store.google.keys, true)
		local sheet = g:spreadsheet(self.store.google.spreadsheetid)
		sheet:save_ssml(args.google.sheetname, mem:dump())
	end

	return {value = mem.data[args.name]}, args.status or ''
end)

-- historyに追加
hub.add_command('history_push', function(self, args)
    local h = history.create(args.name, args.options)
    if args.type ~= '' then
        args.value = stringify.decode(args.type, args.value)
    end
    local success = h:push(args.value)
    local status = ''
    if success == true then
    	status = args.status or args.name
	end
    return args.value, status
end)

-- historyを参照
hub.add_command('history_head', function(self, args)
    local h = history.create(args.name, args.options)
    local values = {}
    for v in h:elements(args.count) do
    	table.insert(values, v)
    end
    local status
    if #values == 0 then status = 'empty' end
    return values, status or args.status or args.name
end)

-- historyを逆順に参照
hub.add_command('history_last', function(self, args)
    local h = history.create(args.name, args.options)
    local values = {}
    for v in h:elements(args.count, true) do
    	table.insert(values, v)
    end
    local status
    if #values == 0 then status = 'empty' end
    return values, status or args.status or args.name
end)

-- historyをクリア
hub.add_command('history_clear', function(self, args)
    local h = history.create(args.name, args.options)
	h:clear()
	return args.name, ''
end)

-- HTTPリクエストを送信
hub.add_command('http', function(self, args)
	local response = http_client.request(args.request)
	local status = ''
	if response.statuscode ~= 200 then
		status = 'error'
	end
	return response, args.status or ''
end)

-- hubのdefault関数作成
function hub_default(self, event)
	self.context[event.name] = event.result
	local status = (event.status and string.format(':%s', event.status)) or ''
	if status == ':' then status = '' end
	local key = event.name..status
    logger.info('event', key)

	local command = self._listeners[key]
	if command then
		command = util.table_convert(command, function(value)
			if type(value) == 'string' then
				return filling.apply(value, {
					event = event,
					context = self.context,
					store = self.store,
				})
			else
				return value
			end
		end)
		logger.debug('command', command)
		if #command > 0 then
			self:push(unpack(command))
		else
			self:push(command)
		end
    else
        logger.info('no command', key)
	end
end

function m.create(name, self)
	local h = hub.create(name, {
		context = self.context or {},
		store = self.store or {},
		_listeners = self.listeners or {},
	})
    h:on_default(hub_default)
	return h
end

return m
