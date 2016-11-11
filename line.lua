-- LINE Message APIを使う

local logger = (require 'logger').get('line')
local http_client = require 'http_client'
local stringify = require 'stringify'

local m = {}

-- Message API 送信
function m.message(access_token, message_type, data)
    logger.trace('message', access_token)
    logger.info('message', message_type)
    logger.debug('message', data)

    return http_client.request {
        url = 'https://api.line.me/v2/bot/message/'..message_type,
        method = 'POST',
        headers = {
            ['Content-Type'] = 'application/json; charset=UTF-8',
            ['Authorization'] = 'Bearer '..access_token,
        },
        data = stringify.encode(data),
    }, data
end

-- メッセージを送信
function m.send(args)
    logger.trace('send', args)

    local message_type = args.message_type
    if not message_type and args.replyToken then message_type = 'reply' end
    if not message_type and args.to then message_type = 'push' end

    local messages = {}
    for i,v in ipairs(args.messages or {args}) do
        local type = 'text'
        if v.imageUrl or v.originalContentUrl then type ='image' end
        if v.stickerId then type = 'sticker' end

        local message = {
            type = type,
            text = stringify.encode(v.text),
            originalContentUrl = v.originalContentUrl or v.imageUrl,
            previewImageUrl = v.previewImageUrl or v.imageUrl,
            stickerId = v.stickerId,
            packageId = v.packageId,
        }
        if message.originalContentUrl then
            message.originalContentUrl = message.originalContentUrl:gsub('http://', 'https://')
        end
        if message.previewImageUrl then
            message.previewImageUrl = message.previewImageUrl:gsub('http://', 'https://')
        end

        table.insert(messages, message)
    end

    local data = {messages = messages}
    if message_type == 'reply' then
        data.replyToken = args.replyToken
    elseif message_type == 'push' then
        data.to = args.to
    end

    return m.message(args.access_token, message_type, data)
end

return m
