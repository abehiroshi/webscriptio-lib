-- storageを利用

local m = {}

-- キューの関数定義
local queue = {}

-- キューに追加
function queue.push(self, x)
	lease.acquire(self.count)

	local counter = (storage[self.count] or 0) + 1
	storage[self.count] = counter
	storage[self.store..counter] = json.stringify(x)

	lease.release(self.count)
end

-- キューから取り出し
function queue.pop(self)
	lease.acquire(self.head)

	local header = storage[self.head] or 1
	local ret = storage[self.store..header]
	if ret then
		storage[self.head] = header + 1
	elseif storage[self.head] then
		-- 何もなければstorageをクリア
		lease.acquire(self.count)
			if (storage[self.count] or 0) - header < 0 then
				storage[self.count] = nil
				storage[self.head] = nil
			end
		lease.release(self.count)
	end

	lease.release(self.head)
	
	if ret then
		storage[self.store..header] = nil
		return json.parse(ret)
	else
		return nil
	end
end

-- キューの件数
function queue.count(self)
	return (storage[self.count] or 0) - (storage[self.head] or 1) + 1
end

-- キューをクリア
function queue.clear(self)
	lease.acquire(self.head)
	lease.acquire(self.count)

	local header = storage[self.head] or 1
	local counter = (storage[self.count] or 0)
	for i = header, counter do
		storage[self.store..i] = nil
	end
	storage[self.count] = nil
	storage[self.head] = nil

	lease.release(self.count)
	lease.release(self.head)
end

function queue.head(self, offset)
	local header = (storage[self.head] or 1) + (offset or 0)
	local ret = storage[self.store..header]
	if ret then
		return json.parse(ret)
	else
		return nil
	end
end

function queue.last(self, offset)
	local counter = (storage[self.count] or 0) - (offset or 0)
	local ret = storage[self.store..counter]
	if ret then
		return json.parse(ret)
	else
		return nil
	end
end

-- キューを作成
function m.queue(id, prefix)
	local self = {
		count = (prefix or '')..'queue_count_'..id,
		store = (prefix or '')..'queue_store_'..id,
		head = (prefix or '')..'queue_head_'..id,
		capacity = (prefix or '')..'queue_count_'..id,
	}
	storage[self.capacity] = storage[self.capacity] or 0
	
	return {
		-- キューに追加
		push = function(x) return queue.push(self, x) end,
		-- キューから取り出し
		pop = function() return queue.pop(self) end,
		-- キューの件数
		count = function() return queue.count(self) end,
		-- キューをクリア
		clear = function() return queue.clear(self) end,
		-- 先頭の要素を参照
		head = function(offset) return queue.head(self, offset) end,
		-- 末尾の要素を参照
		last = function(offset) return queue.last(self, offset) end,
		
		-- 容量を設定
		setCapacity = function(n)
			storage[self.capacity] = tonumber(n) or storage[self.capacity]
		end,
	}
end

return m
