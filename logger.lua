-- ログ出力

local m = {}

local stringify = require 'stringify'

-- ログ出力関数
local logger = function() end

-- ログ出力関数を初期化
function m.init(fn)
    if type(fn) == 'function' then
        logger = fn
    end
end

-- ログレベル
local levels = {
    ERROR = 1,
    INFO  = 2,
    DEBUG = 3,
}
local level = levels.ERROR

-- ログレベルを設定
function m.level(l)
    level = levels[l] or level
end

-- インスタンス作成
function m.get(category)
    function write(level, ...)
        local text = os.date("![%Y/%m/%d %H:%M:%S]")..'['..level..']['..(category or '')..']'
        for i,v in ipairs({...}) do
            text = text..' '..stringify.encode(v)
        end
        logger(text)
    end
    return {
        error = function(...)
            write('ERROR', ...)
        end,
        info = function(...)
            if level >= levels.INFO then
                write('INFO ', ...)
            end
        end,
        debug = function(...)
            if level >= levels.DEBUG then
                write('DEBUG', ...)
            end
        end,
    }
end

return m