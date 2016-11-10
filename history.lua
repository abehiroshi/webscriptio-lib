-- 履歴

local logger = (require 'logger').get('history')
local queue = require 'queue'
local stringify = require 'stringify'

local m = {}

-- 容量以内に要素の数を調整する
function m:adjust()
    while self._queue:count() > (self._options.capacity or 1000) do
       self._queue:pop()
    end
end

-- 要素を追加する
function m:push(value)
    logger.info('push', self._id)
    logger.debug('push', value)

    if self._options.unique then
        local last = self._queue:last()
        logger.trace('push compare to', last)
        if last and stringify.encode(value) == stringify.encode(last) then
            logger.info('push skip')
            return false
        end
    end

    self._queue:push(value)
    self:adjust()
    return true
end

-- 全ての要素を参照するイテレータ
function m:elements(max_count, reverse)
    logger.info('elements', self._id, max_count, reverse)
    local index = -1

    return function()
        index = index + 1
        if max_count and index >= tonumber(max_count) then
            return
        end

        logger.trace('elements next', index)
        if reverse == true then
            return self._queue:last(index)
        else
            return self._queue:head(index)
        end
    end
end

-- 履歴の件数
function m:count()
    return self._queue:count()
end

-- 履歴をクリア
function m:clear()
    self._queue:clear()
end

-- 履歴を作成
function m.create(name, options)
    logger.debug('create', name, options)
    local self = {}
    self._id = 'history/'..name
    self._queue = queue.create(self._id)
    self._options = options or {}
    return setmetatable(self, {__index = m})
end

return m