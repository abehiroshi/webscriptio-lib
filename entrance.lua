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
    logger.info('entry start', request)

    if request and request.body then
        local result, body = pcall(json.parse, request.body)
        if result and type(body) == 'table' then
            logger.debug('json.parse', body)
            request.body = body
        end
    end

    self._dispatcher:fire('entry', request)

    logger.info('entry end')
end

function m:result()
    return 'nothing'
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