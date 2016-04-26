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

-- テーブルをキーでソートされた{key,value}の配列に変換
function m.sortedPairs(t)
    local keyvals = {}
    for k, v in pairs(t) do
    	table.insert(keyvals, {key=k, val=v})
    end
    table.sort(keys, function(a, b) return a.key < b.key end)
    return ipairs(keys)
end

return m
