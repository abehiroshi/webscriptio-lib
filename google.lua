-- Google API

local m = {}
local spreadsheet = {}

-- アクセストークンを再取得する
function m.refresh(self)
	local response = http.request {
		url = "https://www.googleapis.com/oauth2/v4/token",
		method = "POST",
		data = {
			refresh_token = self.refresh_token,
			client_id = self.client_id,
			client_secret = self.client_secret,
			grant_type = "refresh_token",
		}
	}

	local result = json.parse(response.content)
	self.auth_token = result.token_type .." ".. result.access_token
end

-- ファイル一覧を取得する
function m.files(self)
	local response = http.request {
		url = "https://www.googleapis.com/drive/v3/files",
		method = "GET",
		headers = {Authorization = self.auth_token}
	}
	return json.parse(response.content)
end

-- Googleのインスタンス作成
function m.create(keys)
	return setmetatable(keys, {__index = m})
end

-- スプレッドシートのセルの値を取得する
function spreadsheet.values(self, range)
	local response = http.request {
		url = "https://sheets.googleapis.com/v4/spreadsheets/"..self.spreadsheetid.."/values/"..range,
		method = "GET",
		headers = {Authorization = self.auth_token},
	}
	return json.parse(response.content)
end

-- スプレッドシートマークアップ形式(ssml)を解析する
function parse_ssml(values, row, col, context)
	row = row or 1
	if not values[row] then return context, row-1 end

	col = col or 1
	local current = values[row][col]
	if not current or current == "" then return context, row end

	local rval = values[row][col+1]
	if not rval or rval == "" then return current, row end

	local right, rrow = parse_ssml(values, row, col+1)
	row = rrow+1

	context = context or {}
	if current == "-" then
		table.insert(context, right)
		if not (values[row] and values[row][col] == "-") then
			return context, row-1
		end
	else
		context[current] = right
		if not (values[row] and values[row][col-1] == "") then
			return context, row-1
		end
	end

	return unpack{parse_ssml(values, row, col, context)}
end

-- スプレッドシートマークアップ形式データ(ssml)を読み込む
function spreadsheet.load_ssml(self, range)
	return parse_ssml(self:values(range).values)
end

-- スプレッドシートのセルの値を更新する
function spreadsheet.update(self, updateCells)
	local response = http.request {
		url = "https://sheets.googleapis.com/v4/spreadsheets/"..self.spreadsheetid..":batchUpdate",
		method = "POST",
		headers = {Authorization = self.auth_token},
		data = json.stringify({requests = {{updateCells = updateCells}}}),
	}
	return json.parse(response.content)
end

-- スプレッドシートのインスタンス作成
function m.spreadsheet(self, spreadsheetid)
	local self = json.parse(json.stringify(self))
	self.spreadsheet = spreadsheet
	return setmetatable(self, {__index = spreadsheet})
end

return m
