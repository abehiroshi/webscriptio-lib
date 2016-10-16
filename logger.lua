-- ログ出力

local m = {}

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
function m.level(_level, category)
    if levels[_level] then
        level[category or ''] = levels[_level]
    end
end

function judge_level(category, _level)
    return function()
        return (level[category] or level['']) >= _level
    end
end

-- インスタンス作成
function m.get(category)
    function write(_level, ...)
        local text = os.date("![%Y/%m/%d %H:%M:%S]")..'['.._level..']['..(category or '')..']'
        for i,v in ipairs({...}) do
            if type(v) == 'table' then
                text = text..' '..json.stringify(v):gsub('\\u[0-9a-f][0-9a-f][0-9a-f][0-9a-f]', function(s)
            		return json.parse('"'..s..'"')
                end)
            else
                text = text..' '..tostring(v)
            end
        end
        logger(text)
    end
    local is_info  = judge_level(category, levels.INFO)
    local is_debug = judge_level(category, levels.DEBUG)
    local is_trace = judge_level(category, levels.TRACE)

    return {
        error = function(...)
            write('ERROR', ...)
        end,
        info = function(...)
            if is_info() then write('INFO ', ...) end
        end,
        debug = function(...)
            if is_debug() then write('DEBUG', ...) end
        end,
        trace = function(...)
            if is_trace() then write('TRACE', ...) end
        end,
        is_info = is_info,
        is_debug = is_debug,
        is_trace = is_trace,
    }
end

return m