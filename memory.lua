-- storageに記憶するデータ管理

local m = {}

local storagify = require 'storagify'
local stringify = require 'stringify'

-- storageアクセス時の型変換フック
function hook(self)
	return {
		decode = function(index, value)
			return stringify.decode(self._types[index], value)
		end,

		encode = function(index, value)
			if value == nil then
				self._types[index] = nil
			else
				self._types[index] = type(value)
			end
			self._meta.types = stringify.encode(self._types)

			return stringify.encode(value)
		end,
	}
end

-- 記憶をクリアする
function m:clear()
	for k,v in pairs(self._types) do
		self.data[k] = nil
	end
	self._types = {}
	self._meta.types = nil
end

-- 記憶をダンプする
function m:dump()
	local data = {}
	for k,v in pairs(self._types) do
		data[k] = self.data[k]
	end
	return data
end

-- ダンプから読み込む
function m.load(prefix, data)
	local self = m.create(prefix)
	self:clear()

	if type(data) == 'table' then
		for k,v in pairs(data) do
			self.data[k] = data[k]
		end
	end

	return self
end

-- 記憶を破棄する
function m.destroy(prefix)
	local meta = storagify.create(prefix..'/meta')
	local meta_types = meta.types
	meta.types = nil
	if type(meta_types) == 'string' then
		local status, types = pcall(json.parse, meta_types)
		if status then
			local data = storagify.create(prefix..'/data')
			for k,v in pairs(types) do
				data[k] = nil
			end
		end
	end
end

-- 記憶を生成する
function m.create(prefix)
	local self = setmetatable({}, {__index = m})
	self.data = storagify.create(prefix..'/data', hook(self))
	self._meta = storagify.create(prefix..'/meta')

	if type(self._meta.types) == 'string' then
		self._types = stringify.decode('table', self._meta.types)
	else
		self._types = {}
	end

	return self
end

return m
