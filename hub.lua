-- ハブ

local m = {}

local store = require 'storage'

-- コマンド
local commands = {}

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

-- ハブ
local hub = {}

-- コマンドを実行する
function hub.command(self, command, run)
    self.requests.push(command)
    if run then
        return self:next()
    end
    return true
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

-- イベントを通知する
function hub.notify(self, event, listener)
end

-- 次のコマンドを実行する
function hub.next(self)
    local req = self.requests.pop()
    if not req then
        return false
    end
    
    local f = commands[req.command]
    local ret, err = f(req.params)    
    local event = {
		command = req.command,
		params = req.params,
		result = ret,
		error = err,
    }
    self.events.push(event)
    local listener = self.listeners[req.command]
    if listener then
        listener(event)
    end
    self:notify(event, listener)
    
    return true, not err
end

-- storageをクリアする
function hub.clear(self)
    self.requests.clear()
    self.events.clear()
end

-- ハブを生成する
m.new = function(name, args)
    local self = args or {}
    setmetatable(self, {__index = hub})
    self.listeners = {}
    self.requests = store.queue('hub_requests_'..name)
    self.events = store.queue('hub_events_'..name)
    return self
end

return m
