-- ユーティリティ

local m = {}

local lom = require 'lxp.lom'

-- 文字列をURLエンコード
function m.urlencode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w%-%_%.%~])",
            function(c) return string.format("%%%02X", string.byte(c)) end)
    end
    return str
end

-- テーブルをキーでソートされた{key,val}でイテレート
function m.ipairsSorted(t)
    local kv = {}
    for k, v in pairs(t) do
    	table.insert(kv, {key=k, val=v})
    end
    table.sort(kv, function(a, b) return a.key < b.key end)
    return ipairs(kv)
end

-- テーブルのキーと値をURLクエリ文字列にする
function m.toQuery(t)
    local query = {}
    for i, kv in m.ipairsSorted(t) do
        table.insert(query, kv.key..'='..m.urlencode(kv.val or ''))
    end
    return table.concat(query, '&')
end

-- 配列を畳み込み
function m.reduce(array, init, fn)
	local cxt = init
	for i,v in ipairs(array) do
		local ret = fn(cxt, i, v)
		if ret ~= nil then cxt = ret end
	end
	return cxt
end

-- XMLをテーブル構造にする
function m.parseXml(xml)
    return m.simplifyLom(lom.parse(xml))
end

-- lxp.lomで変換したテーブルを単純化する
function m.simplifyLom(x)
	if type(x) ~= 'table' then return x
	elseif #x == 1 then return m.simplifyLom(x[1])
	end

	local result = {}
	for i,v in ipairs(x) do
		if not v.tag then
			table.insert(result, v)
		else
			local child = m.simplifyLom(v)
			if #v.attr > 0 then
				if type(child) ~= 'table' then child = {value=child} end
				child = m.reduce(v.attr, child,
							function(c,i,val) c[val] = v.attr[val] end)
			end
			if type(child) == 'table' then
				local elements = result[v.tag] or {}
				table.insert(elements, child)
				result[v.tag] = elements
			else
				result[v.tag] = child
			end
		end
	end
	return result
end

-- table_convertの内部処理：値を変換する
function convert_value(value, converter)
	if type(value) == 'table' then
		return m.table_convert(value, converter)
	else
		return converter(value)
	end
end

-- table内の値を変換する
function m.table_convert(t, converter)
	if type(t) ~= 'table' then return t end
	if type(converter) ~= 'function' then return t end

	if #t > 0 then
		for i,v in ipairs(t) do
			t[i] = convert_value(v, converter)
		end
	else
		for k,v in pairs(t) do
			t[k] = convert_value(v, converter)
		end
	end
	return t
end

return m
