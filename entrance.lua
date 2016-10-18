-- HTTP Request入口

-- ログ初期化
local _logger = require 'logger'
local logger = _logger.get('receiver')
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

    local result, content = pcall(json.parse, request.content)
    if result and type(content) == 'table' then
        logger.debug('json.parse', content)
        request.content = content
    end
    self._dispatcher:fire('entry', request)

    logger.info('entry end')
end

-- 入口を作成する
function m.create(name, store_name)
    logger.info('create', name, store_name)
    local d = dispatcher.create(name, {
        listeners = memory.create(name).data,
        store = memory.create(store_name).data,
        context = {},
    })
    return setmetatable({_dispatcher = d}, {__index = m})
end

return m