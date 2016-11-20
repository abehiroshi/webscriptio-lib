-- キャッシュ

local m = {}

function m.get(name)
    local ret = m[name]
    if not ret then
        ret = {}
        m[name] = ret
    end
    return ret
end

return m