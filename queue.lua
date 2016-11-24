-- キュー

local m = {}

local memory = require 'memory'

-- キュー操作をロック
function m:acquire()
    if self._id then
        lease.acquire(self._id)
    end
end

-- キュー操作のロック解除
function m:release()
    if self._id then
        lease.release(self._id)
    end
end

-- キューに追加
function m:push(value)
	self:acquire()

	local counter = (self._memory.data.count or 0) + 1
	self._memory.data.count = counter
	self._memory.data[counter] = value

	self:release()
end

-- キューから取り出し
function m:pop()
	self:acquire()

	local header = self._memory.data.head or 1
	local ret = self._memory.data[header]
	if ret then
		self._memory.data[header] = nil
		self._memory.data.head = header + 1
	else
		-- 何もなければmemoryをクリア
        self:_clear()
	end

	self:release()
	return ret
end

-- キューの件数
function m:count()
	return (self._memory.data.count or 0) - (self._memory.data.head or 1) + 1
end

-- memoryをクリア
function m:_clear()
	if self._id then
	    self._memory:clear()
	else
	    self._memory = {data={}, clear=function(self) self.data={} end}
	end
end

-- キューをクリア
function m:clear()
    self:acquire()
    self:_clear()
    self:release()
end

-- 先頭の要素を参照
function m:head(offset)
	local header = (self._memory.data.head or 1) + (offset or 0)
	return self._memory.data[header]
end

-- 末尾の要素を参照
function m:last(offset)
	local counter = (self._memory.data.count or 0) - (offset or 0)
	return self._memory.data[counter]
end

-- キューを作成
function m.create(name)
    local self = {}
    if name and name ~= '' then
        self._id = 'queue/'..name
        self._memory = memory.create(self._id)
    else
        self._memory = {data={}, clear=function(self) self.data={} end}
    end

    return setmetatable(self, {__index = m})
end

return m