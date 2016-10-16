-- 履歴

local logger = (require 'logger').get('history')
local queue = require 'queue'

local m = {}

-- 容量以内に要素の数を調整する
function m:adjust()
    while self._queue:count() > self._capacity do
       self._queue:pop()
    end
end

-- 要素を追加する
function m:push(value)
    self._queue:push(value)
    self:adjust()
end

-- 全ての要素を参照するイテレータ
function m:elements()
    local index = -1
    return function()
        index = index + 1
        return self._queue:head(index)
    end
end

-- 履歴を作成
function m.create(name)
    local self = {}
    self._id = 'history/'..name
    self._queue = queue.create(self._id)
    self._capacity = 100
    return setmetatable(self, {__index = m})
end

return m