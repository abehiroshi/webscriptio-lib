-- ログ運用

local logger = require 'logger'
local history = require 'history'
local memory = require 'memory'

local m = {}

function m.load(memory_name)
    local config = memory.create(memory_name).data

    local hist = history.create(
        config.history_name or 'log',
        config.history_capacity or 1000
    )
    logger.init(function(text)
        log(text)
        hist:push(text)
    end)

    logger.level(config.root_level)
    for k,v in pairs(config.levels or {}) do
        logger.level(v, k)
    end

    return m
end

return m
