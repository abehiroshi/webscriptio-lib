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

-- 記憶を破棄する
function m:destroy()
	self:clear()
	self._meta.prefix = nil
	self._meta = nil
	self.data = nil
end

-- 記憶をダンプする
function m:dump()
	local d = {
		_meta = {
			prefix = self._meta.prefix,
		},
		_types = self._types,
		data = {},
	}
	for k,v in pairs(d._types) do
		d.data[k] = self.data[k]
	end
	return d
end

-- ダンプから読み込む
function m.load(d)
	local self = m.create(d._meta.prefix)
	self:clear()

	for k,v in pairs(d._types) do
		self.data[k] = d.data[k]
	end
	return self
end

-- 記憶を生成する
function m.create(prefix)
	local self = setmetatable({}, {__index = m})
	self.data = storagify.create(prefix..'/data', nil, hook(self))

	self._meta = storagify.create(prefix..'/meta')
	self._meta.prefix = prefix

	self._types = json.parse(self._meta.types or '{}')

	return self
end

return m
