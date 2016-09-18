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
			self._meta.types = json.stringify(self._types)

			return stringify.encode(value)
		end,
	}
end

-- 記憶をクリアする
function m:clear()
	for k,v in pairs(json.parse(self._meta.types)) do
		self.data[k] = nil
		self._types[k] = nil
	end
	self._meta.types = nil
end

-- 記憶をダンプする
function m:dump()
	local d = {
		_meta = {
			prefix = self._meta.prefix,
			struct = self._meta.struct,
			types = self._meta.types,
		},
		data = {},
	}
	for k,v in pairs(json.parse(self._types)) do
		d.data[k] = self.data[k]
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

	self._meta = storagify.create(prefix..'/meta')
	self._meta.prefix = prefix
	if type(struct) == 'table' then
		self._meta.struct = json.parse(json.stringify(struct))
	end

	self._types = json.parse(self._meta.types or '{}')

	return self
end

return m
