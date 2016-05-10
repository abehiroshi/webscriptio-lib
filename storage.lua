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



-- キューを作成
function m.queue(id, prefix)
	local self = {
		count = (prefix or '')..'queue_count_'..id,
		store = (prefix or '')..'queue_store_'..id,
		head = (prefix or '')..'queue_head_'..id,
		capacity = (prefix or '')..'queue_count_'..id,
	}
	local count = self.count
	local store = self.store
	local head = self.head
	local capacity = self.capacity
	
	storage[capacity] = storage[capacity] or 0
	
	return {
		-- キューに追加
		push = function(x) return queue.push(self, x) end,

		-- キューから取り出し
		pop = function()
			lease.acquire(head)
				local header = storage[head] or 1
				local ret = storage[store..header]
				if ret then
					storage[head] = header + 1
				elseif storage[head] then
					-- 何もなければstorageをクリア
					lease.acquire(count)
						if (storage[count] or 0) - header < 0 then
							storage[count] = nil
							storage[head] = nil
						end
					lease.release(count)
				end
			lease.release(head)
			
			if ret then
				storage[store..header] = nil
				return json.parse(ret)
			else
				return nil
			end
		end,

		-- キューの数
		count = function()
			return (storage[count] or 0) - (storage[head] or 1) + 1
		end,

		-- キューをクリア
		clear = function()
			lease.acquire(head)
			lease.acquire(count)
				local header = storage[head] or 1
				local counter = (storage[count] or 0)
				for i = header, counter do
					storage[store..i] = nil
				end
				storage[count] = nil
				storage[head] = nil
			lease.release(count)
			lease.release(head)
		end,

		head = function(index)
			local header = (storage[head] or 1) + (index or 0)
			local ret = storage[store..header]
			if ret then
				return json.parse(ret)
			else
				return nil
			end
		end,
		
		last = function(index)
			local counter = (storage[count] or 0) - (index or 0)
			local ret = storage[store..counter]
			if ret then
				return json.parse(ret)
			else
				return nil
			end
		end,
		
		setCapacity = function(n)
			storage[capacity] = tonumber(n) or storage[capacity]
		end,
	}
end

return m
