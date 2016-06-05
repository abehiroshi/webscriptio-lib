-- ハブ

local m = {}

local store = require 'storage'

-- ハブ
local hub = {}

-- コマンドを実行する
function hub.command(self, command, params)
    self.requests.push({command = command, params = params})
    self:notify(command, params)
end

-- コマンドを追加する
function hub.push(self, args)
    self:command(args.command, args.params, args.run)
end

-- コマンド追加を通知する
function hub.notify(self, command, params)
    while self:next() do end
end

-- イベントリスナを登録する
function hub.on(self, command, callback)
    if type(command) ~= 'string' then
        return false, 'コマンド名は文字列です'
    elseif type(callback) ~= 'function' then
        return false, 'コールバックは関数です'
    end
    self.listeners[command] = callback
    return true
end

-- デフォルトのイベントリスナを登録する
function hub.on_default(self, callback)
    if type(callback) ~= 'function' then
        return false, 'コールバックは関数です'
    end
    self.default_listener = callback
    return true
end

-- 次のコマンドを実行する
function hub.next(self)
    local req = self.requests.pop()
    if not req then
        return false
    end

    local f = self[req.command] or (function() return 'コマンドがありません', true end)
    local ret, err = f(self, req.params)

    local event = {
		command = req.command,
		params = req.params,
		result = ret,
		error = err,
    }
    self.events.push(event)
    local listener = self.listeners[req.command] or self.default_listener
    local ret_listener
    if listener then
        ret_listener = listener(self, event)
    end

    return true, not err
end

-- storageをクリアする
function hub.clear(self)
    self.requests.clear()
    self.events.clear()
end

-- ハブを生成する
m.new = function(name, args)
    local self = setmetatable(args or {}, {__index = hub})
    self.listeners = {}
    self.requests = store.queue('hub_requests_'..name)
    self.events = store.queue('hub_events_'..name)
    return self
end


-- ハブで実行可能なコマンド
local commands = {}
setmetatable(hub, {__index = commands})

-- コマンドを追加
function m.add_command(name, f)
    if type(name) ~= 'string' then
        return false, 'コマンド名は文字列です'
    elseif type(f) ~= 'function' then
        return false, 'コマンドは関数です'
    end
    commands[name] = f
    return true
end


return m
