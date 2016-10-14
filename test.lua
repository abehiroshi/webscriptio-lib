-- テスト

local logger = (require 'logger').get('test')

local m = {}

function m.log_info(s)
    logger.info(s)
end

return m