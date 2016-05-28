-- storageを便利にする

local m = {}

-- storageアクセス用のmetatableを作成する
function metastorage(prefix, struct)
	local p = prefix..'/'
	for k,v in pairs(struct) do
		setmetatable(v, metastorage(p..k, v))
	end
	return {
		__index = function(table, index)
			return (struct and rawget(struct, index)) or storage[p..index]
		end,
		__newindex = function(table, index, value)
			storage[p..index] = value
		end,
	}
end

-- storageアクセス用オブジェクトを作成する
function m.create(prefix, struct)
	local s = struct or {}
	setmetatable(s, metastorage(prefix, s))
	return s
end

return m
