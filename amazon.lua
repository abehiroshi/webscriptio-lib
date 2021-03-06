-- AmazonのAPIを使う

local http_client = require 'http_client'
local util = require 'util'

local m = {}

-- Amazon商品画像URLをhttpsに変換
function convertImageUrl(url)
    return url:gsub('^http://ecx.images[-]amazon.com', 'https://images-na.ssl-images-amazon.com')
end

-- AmazonにHTTPリクエストを送信する
function m.request(args)
    local info = args.info
    local params = args.params

    params.AWSAccessKeyId = info.AWSAccessKeyId
    params.AssociateTag = info.AssociateTag
    params.Version = info.Version
    params.Timestamp = os.date("!%Y-%m-%dT%T.000Z")
    params.Signature = base64.encode(
        crypto.hmac(
            info.SecretAccessKey,
            (info.method.."\n"..
                info.endpoint.."\n"..
				info.uri.."\n"..
				util.toQuery(params)),
            crypto.sha256).digest())

    return http_client.request {
        url = info.protocol..'://'..info.endpoint..info.uri,
        params = params,
    }
end

-- Amazonで商品検索する
function m.itemsearch(args)
    local params = args.params
    params.Operation = 'ItemSearch'
    params.Service = 'AWSECommerceService'
    params.SearchIndex = params.SearchIndex or 'All'
    params.ResponseGroup = params.ResponseGroup or 'Medium,Offers'
    local response = m.request {info = args.info, params = params}

    local ret = {}
    -- HTTPステータスコード
    if response.statuscode ~= 200 then
        ret.error = {
            reason = 'statuscode',
            statuscode = response.statuscode,
        }
        return ret
    end

    ret.result = util.parseXml(response.content)
    -- 検索結果有無
    if not (ret.result.Items and ret.result.Items[1].Item) then
        ret.error = {
            reason = 'itemcount',
            itemcount = 0,
        }
        return ret
    end

    ret.Items = {}
    for i, v in ipairs(ret.result.Items[1].Item) do
        local item = {}
        table.insert(ret.Items, item)

        item.ASIN = v.ASIN
        item.URL = 'http://amazon.jp/dp/'..v.ASIN
        item.DetailPageURL = v.DetailPageURL
        if v.ItemAttributes then item.Title = v.ItemAttributes[1].Title end
        if v.MediumImage then item.MediumImageURL = convertImageUrl(v.MediumImage[1].URL) end
        if v.LargeImage then item.LargeImageURL = convertImageUrl(v.LargeImage[1].URL) end
        if v.Offers and v.Offers[1].Offer and v.Offers[1].Offer[1].OfferListing then
            item.OfferListingId = v.Offers[1].Offer[1].OfferListing[1].OfferListingId
            if v.Offers[1].Offer[1].OfferListing[1].Price then
                item.FormattedPrice = v.Offers[1].Offer[1].OfferListing[1].Price[1].FormattedPrice
            end
        end
    end

    return ret
end

return m
