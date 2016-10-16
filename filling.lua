-- テンプレートエンジン

local m = {}

-- テンプレート適用関数 デフォルトは何もしない
local filler = function(x) return x end

-- lustacheを使用する
function m.lustache(_lustache)
    filler = function(...)
        return lustache:render(...)
    end
end

-- テンプレート文字列にパラメータを適用する
function m.apply(text, args)
    return filler(text, args)
end

return m