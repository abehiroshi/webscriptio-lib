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

return m
