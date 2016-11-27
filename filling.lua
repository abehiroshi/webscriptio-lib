-- テンプレートエンジン

local logger = (require 'logger').get('filling')
local stringify = require 'stringify'

local m = {}

-- テンプレート適用関数 デフォルトは何もしない
local filler = function(x) return x end

-- lustacheを使用する
function m.lustache(_lustache)
    filler = function(...)
        return _lustache:render(...)
    end
end

-- テンプレート文字列にパラメータを適用する
function m.apply(text, args)
    logger.debug('apply start', text)
    logger.trace(args)
    if not args['$tostring'] then
        args['$tostring'] = stringify.encode
    end

    local ret =  filler(text, args)
    logger.debug('apply end', ret)
    return ret
end

return m