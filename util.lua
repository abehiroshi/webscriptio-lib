-- ユーティリティ

local m = {}

-- URLエンコード
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

-- テーブルをURLクエリ形式の文字列にする
function m.toQuery(t)
    local query = {}
    for i, kv in m.ipairsSorted(t) do
        table.insert(query, kv.key..'='..m.urlencode(kv.val or ''))
    end
    return table.concat(query, '&')
end

return m
