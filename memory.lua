-- storageに記憶するデータ管理

local m = {}

local storagify = require 'storagify'

-- 型変換用の関数
local converter = {
	table = {
		encode = json.stringify,
		decode = json.parse,
	},
	number = {
		decode = tonumber,
	},
	boolean = {
		decode = function(b)
			return b == 'true'
		end,
	}
}

-- storageアクセス時の型変換フック
function hook(self)
	return {
		decode = function(index, value)
			local c = converter[self.keys[index]]
			if c and c.decode then
				return c.decode(value)
			else
				return value
			end
		end,

		encode = function(index, value)
			local t = type(value)
			local c = converter[t]
			self.keys[index] = t
			if c and c.encode then
				return c.encode(value)
			else
				return value
			end
		end,
	}
end

-- キー情報のメタテーブルを作成する
function metakeys(storage_keys)
	return {
		__newindex = function(table, index, value)
			rawset(table, index, value)
			storage[storage_keys] = json.stringify(table)
		end,
	}
end

-- キー情報をstorageから読み込む
function loadkeys(storage_keys)
	local keys_string = storage[storage_keys]
	local keys = (keys_string and json.parse(keys_string)) or {}
	return setmetatable(keys, metakeys(storage_keys))
end

-- 記憶をクリアする
function m.clear(self)
	for k,v in pairs(self.keys) do
		storage[k] = nil
	end
	storage[self.storage_keys] = nil
	self.keys = setmetatable({}, metakeys(self.storage_keys))
end

-- 記憶をダンプする
function m.dump(self)
	local d = {
		[self.storage_keys] = storage[self.storage_keys]
	}
	for k,v in pairs(self.keys) do
		d[k] = storage[k]
	end
	return d
end

-- 記憶を生成する
function m.create(prefix, struct)
	local self = setmetatable({}, {__index = m})

	self.storage_keys = prefix..'/keys'
	self.keys = loadkeys(self.storage_keys)
	self.data = storagify.create(prefix..'/data', struct, hook(self))

	return self
end

return m
