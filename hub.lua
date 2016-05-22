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
function hub.command(self, args)
    local f = commands[args.command]
    local ret, err = f(args.params)    
    self.events.push({
		event = 'command',
		command = args.command,
		params = args.params,
		result = ret,
		error = err,
    })
    self:notify('event')
    return true
end

-- 状態変化通知
function hub.notify(self, name)
end

-- storageをクリアする
function hub.clear(self)
    self.events.clear()
end

-- ハブを生成する
m.new = function(name, args)
    local self = args or {}
    setmetatable(self, {__index = hub})
    self.events = store.queue('hub_events_'..name)
    return self
end

return m
