-- storageを便利にする

local m = {}

-- storageアクセス用オブジェクトを作成する
function m.create(prefix, hook)
	local p = prefix..'/'
	local decode = hook and hook.decode
	local encode = hook and hook.encode
	return setmetatable({}, {
		__index = function(table, index)
			local v = storage[p..index]
			if decode then
			    v = decode(index, v)
			end
		    return v
		end,

		__newindex = function(table, index, value)
		    local v = value
		    if encode then
		        v = encode(index, v)
	        end
			storage[p..index] = v
		end,
	})
end

return m
