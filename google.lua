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

-- スプレッドシートのセルの値を更新する
function spreadsheet.updateBatch(self, updateCells)
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
