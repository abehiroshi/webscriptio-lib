-- ログ出力

local m = {}

local stringify = require 'stringify'

local logger = function() end

function m.init(fn)
    logger = fn
end

-- インスタンス作成
function m.get(category)
    category = '['..(category or '')..']'
    return function(...)
        local text = os.date("![%Y/%m/%d %H:%M:%S]")..category
        for i,v in ipairs({...}) do
            text = text..' '..stringify.encode(v)
        end
        logger(text)
    end
end

return m