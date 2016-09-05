-- キュー

local m = {}

local memory = require 'memory'

-- キュー操作をロック
function m:acquire(key)
    if self._share then
        lease.acquire(self._id..'/'..key)
    end
end

-- キュー操作のロック解除
function m:release(key)
    if self._share then
        lease.release(self._id..'/'..key)
    end
end

-- キューに追加
function m:push(value)
	self:acquire('push')

	local counter = (self._memory.count or 0) + 1
	self._memory.count = counter
	self._memory[counter] = value

	self:release('push')
end

-- キューから取り出し
function m:pop()
	self:acquire('pop')

	local header = self._memory.head or 1
	local ret = self._memory[header]
	if ret then
		self._memory[header] = nil
		self._memory.head = header + 1
	else
		-- 何もなければmemoryをクリア
    	self:acquire('push')
        self:_clear()
    	self:release('push')
	end

	self:release('pop')
	return ret
end

-- キューの件数
function m:count()
    self:acquire('pop')
	self:acquire('push')
	local ret = (self._memory.count or 0) - (self._memory.head or 1) + 1
	self:release('push')
    self:release('pop')

    return ret
end

-- memoryをクリア
function m:_clear()
	if self._share then
	    self._memory.clear()
	else
	    self._memory = {}
	end
end

-- キューをクリア
function m:clear()
    self:acquire('pop')
	self:acquire('push')
    self:_clear()
	self:release('push')
    self:release('pop')
end

-- 先頭の要素を参照
function m:head(offset)
	local header = (self._memory.head or 1) + (offset or 0)
	return self._memory[header]
end

-- 末尾の要素を参照
function m:last(offset)
	local counter = (self._memory.count or 0) - (offset or 0)
	return self._memory[counter]
end

-- キューを作成
function m.create(name)
    local self = {}
    if name then
        local id = 'queue/'..name
        self._share = true
        self._id = id
        self._memory = memory.create(id).data
    else
        self._memory = {}
    end

    return setmetatable(self, {__index = m})
end

return m