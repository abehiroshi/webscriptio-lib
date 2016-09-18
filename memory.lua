-- storageに記憶するデータ管理

local m = {}

local storagify = require 'storagify'
local stringify = require 'stringify'

-- storageアクセス時の型変換フック
function hook(self)
	return {
		decode = function(index, value)
			return stringify.decode(self.keys[index], value)
		end,

		encode = function(index, value)
			self.keys[index] = type(value)

			local types = json.parse(self._meta.types or '{}')
			if value == nil then
				types[index] = nil
			else
				types[index] = type(value)
			end
			self._meta.types = json.stringify(types)

			return stringify.encode(value)
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

	self._meta.types = nil
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

-- 記憶を破棄する
function m:destroy()
	self:clear()
	self._meta.prefix = nil
	self._meta.struct = nil
end

-- 記憶を生成する
function m.create(prefix, struct)
	local self = setmetatable({}, {__index = m})
	self.data = storagify.create(prefix..'/data', struct, hook(self))

	self.storage_keys = prefix..'/keys'
	self.keys = loadkeys(self.storage_keys)

	self._meta = storagify.create(prefix..'/meta')
	self._meta.prefix = prefix
	if type(struct) == 'table' then
		self._meta.struct = json.parse(json.stringify(struct))
	end

	return self
end

return m
