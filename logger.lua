-- ログ出力

local m = {}

local stringify = require 'stringify'

-- ログ出力関数
local logger = function() end

-- ログ出力関数を初期化
function m.init(fn)
    logger = fn
end

-- ログレベル
local levels = {
    ERROR = 1,
    INFO  = 2,
    DEBUG = 3,
    TRACE = 4,
}
local level = {
    [''] = levels.ERROR
}

-- ログレベルを設定
function m.level(_level, _category)
    if levels[_level] then
        level[_category or ''] = levels[_level]
    else
end

-- インスタンス作成
function m.get(category)
    if not level[category] then
        level[category] = level['']
    end

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
            if level[category] >= levels.INFO then
                write('INFO ', ...)
            end
        end,
        debug = function(...)
            if level[category] >= levels.DEBUG then
                write('DEBUG', ...)
            end
        end,
        trace = function(...)
            if level[category] >= levels.TRACE then
                write('TRACE', ...)
            end
        end,
        is_info = function()
            return level[category] >= levels.INFO
        end,
        is_debug = function()
            return level[category] >= levels.DEBUG
        end,
        is_trace = function()
            return level[category] >= levels.TRACE
        end,
    }
end

return m