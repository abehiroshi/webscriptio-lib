-- ログ運用

local _logger = require 'logger'
local logger = _logger.get('logdriver')
local history = require 'history'
local memory = require 'memory'

local m = {}

-- ログ設定を読み込み初期化する
function m.load(memory_name)
    logger.info('load', memory_name)
    local config = memory.create(memory_name).data

    local hist = history.create(
        config.history_name or 'log',
        {
            capacity = config.history_capacity,
        }
    )
    _logger.init(function(text)
        log(text)
        hist:push(text)
    end)

    _logger.level(config.root_level)
    for k,v in pairs(config.levels or {}) do
        _logger.level(v, k)
    end

    logger.debug(memory.create(memory_name):dump())
    return m
end

-- ログを表示用のHTMLを作成する
function m.view(args)
    logger.info('view', args)
    args = args or {}

    _logger.level(args.log_level or 'TRACE')
    local loghistory = history.create(args.history_name or 'log')
    local options = {
        max_count = args.max_count or 100,
        start = 'last',
        reverse = true,
    }

    local result = {}
    for v in loghistory:elements(options) do
    	table.insert(result, v)
        logger.trace(v)
    end
    return '<div>'..table.concat(result, '</div><div>')..'</div>',
            {['Content-Type']='text/html; charset=UTF-8'}
end

return m
