-- HTTP Request入口

-- ログ初期化
local _logger = require 'logger'
local logger = _logger.get('entrance')
local history = require 'history'
local loghistory = history.create('log')

_logger.init(function(text)
    log(text)
    loghistory:push(text)
end)

local memory = require 'memory'
local dispatcher = require 'dispatcher'

local m = {}

-- HTTP Requestを受信
function m:entry(request)
    logger.info('entry start')
    logger.debug('entry', request)

    if request and request.body then
        local result, body = pcall(json.parse, request.body)
        if result and type(body) == 'table' then
            logger.trace('entry json.parse', body)
            request.body = body
        end
    end

    local ok, message = pcall(self._dispatcher.fire, self._dispatcher, 'entry', request)
    if not ok then
        logger.error(message)
    end

    logger.info('entry end')
end

-- 入口を作成する
function m.create(dispatcher_name, listener_name, store_name)
    logger.info('create', dispatcher_name, listener_name, store_name)
    local d = dispatcher.create(dispatcher_name, {
        listeners = memory.create(listener_name).data,
        store = memory.create(store_name).data,
        context = {},
    })
    return setmetatable({_dispatcher = d}, {__index = m})
end

return m