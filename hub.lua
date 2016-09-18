-- ハブ

-- 実行可能なコマンド
local commands = {}

local m = setmetatable({}, {__index = commands})

local queue = require 'queue'

-- コマンドを追加する
function m:push(...)
    for i,v in ipairs{...} do
        self.requests:push(v)
    end
    self:notify()
end

-- コマンド追加を通知する
function m:notify()
    while self:next() do end
end

-- イベントリスナを登録する
function m:on(command, callback)
    if type(command) ~= 'string' then
        return false, 'コマンド名は文字列です'
    elseif type(callback) ~= 'function' then
        return false, 'コールバックは関数です'
    end
    self.listeners[command] = callback
    return true
end

-- デフォルトのイベントリスナを登録する
function m:on_default(callback)
    if type(callback) ~= 'function' then
        return false, 'コールバックは関数です'
    end
    self.default_listener = callback
    return true
end

-- 次のコマンドを実行する
function m:next()
    local req = self.requests:pop()
    if not req then
        return false
    end

    local f = self[req.command]
    if f then
        local ret, status = f(self, req.params)
        self:fire(req.command, ret, status, req)
    end

    return true
end

-- イベントを発火する
function m:fire(name, result, status, request)
    local event = {
		name = name,
		result = result,
		status = status,
		request = request,
    }
    local listener = self.listeners[event.name]
    if listener then
        if listener(self, event) then
            return
        end
    end
    self:default_listener(event)
end

-- storageをクリアする
function m:clear()
    self.requests:clear()
end

-- ハブを生成する
function m.create(name, args)
    local self = setmetatable(args or {}, {__index = m})
    self.listeners = {}
    self.requests = queue.create('hub/requests/'..name)
    return self
end

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
