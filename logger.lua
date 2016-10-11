-- ログ出力

local m = {}

local stringify = require 'stringify'

-- ログ出力関数
local logger = function() end

-- ログ出力関数を初期化
function m.init(fn)
    logger = fn
end

-- インスタンス作成
function m.get(category)
    category = '['..(category or '')..']'
    local self = {
        log = function(level, ...)
            local text = os.date("![%Y/%m/%d %H:%M:%S]")..'['..level..']'..category
            for i,v in ipairs({...}) do
                text = text..' '..stringify.encode(v)
            end
            logger(text)
        end
    }
    self.error = function(...) self.log('ERROR', ...) end
    self.info  = function(...) self.log('INFO ', ...) end
    self.debug = function(...) self.log('DEBUG', ...) end
    return self
end

return m