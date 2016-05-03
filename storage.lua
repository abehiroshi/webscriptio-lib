-- storageを利用

local m = {}

-- キューを作成
function m.queue(id)
	local count = 'queue_count_'..id
	local store = 'queue_store_'..id
	local head = 'queue_head_'..id
	return {
		-- キューに追加
		push = function(x)
			lease.acquire(count)
				local counter = (storage[count] or 0) + 1
				storage[count] = counter
			lease.release(count)
			storage[store..counter] = json.stringify(x)
		end,

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
			lease.release(head)
		end
	}
end

return m
