-- storageを便利にする

local m = {}

-- storageアクセス用のmetatableを作成する
function metastorage(prefix, struct, hook)
	local p = prefix..'/'
	for k,v in pairs(struct) do
		setmetatable(v, metastorage(p..k, v, hook))
	end

	local decode = hook and hook.decode
	local encode = hook and hook.encode
	return {
		__index = function(table, index)
		    local v = rawget(struct, index)
		    if v ~= nil then return v end

			v = storage[p..index]
			if decode then
			    return decode(p..index, v)
			else
			    return v
			end
		end,

		__newindex = function(table, index, value)
		    local v = value
		    if encode then
		        v = encode(p..index, v)
	        end
			storage[p..index] = v
		end,
	}
end

-- storageアクセス用オブジェクトを作成する
function m.create(prefix, struct, hook)
	local s = struct or {}
	setmetatable(s, metastorage(prefix, s, hook))
	return s
end

return m
