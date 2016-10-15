-- 文字列化

local logger = (require 'logger').get('stringify')


local m = {}

-- 型変換用の関数
local converters = {
	table = {
		encode = function(t)
			local s = json.stringify(t)
			--[[
			s = s:gsub(
				'"[^"]+\\u[^"]+"',
				function(text)
					text = json.parse(text)
					text = text:gsub('\n', '\\n')
					text = text:gsub('"', '\\"')
					return '"'..text..'"'
				end
			)
			]]
			return s
		end,
		decode = json.parse,
	},
	number = {
	    encode = tostring,
		decode = tonumber,
	},
	boolean = {
	    encode = tostring,
		decode = function(b)
			return b == 'true'
		end,
	},
}

-- 変換実行
function convert(method, typename, value)
    if value == nil then return nil end

	local c = converters[typename]
	if c and c[method] then
		return c[method](value)
	else
		return value
	end
end

-- 文字列に変換
function m.encode(value)
    return convert('encode', type(value), value)
end

-- 文字列から逆変換
function m.decode(typename, value)
    return convert('decode', typename, value)
end

return m