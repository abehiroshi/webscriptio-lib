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
    logger.debug('push', self._id, value)
    self._queue:push(value)
    self:adjust()
end

-- 全ての要素を参照するイテレータ
function m:elements(max_count)
    logger.info('elements', self._id, max_count)
    local index = -1
    if type(max_count) == 'number' and max_count > 0 then
        local count = self._queue:count()
        if max_count < count then
            index = index + count - max_count
        end
    end

    return function()
        index = index + 1
        logger.trace('elements next', self._id, index)
        return self._queue:head(index)
    end
end

-- 履歴をクリア
function m:clear()
    self._queue:clear()
end

-- 履歴を作成
function m.create(name, capacity)
    local self = {}
    self._id = 'history/'..name
    self._queue = queue.create(self._id)
    self._capacity = capacity or 100
    return setmetatable(self, {__index = m})
end

return m