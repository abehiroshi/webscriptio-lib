-- Google API

local http_client = require 'http_client'

local m = {}
local spreadsheet = {}

-- アクセストークンを再取得する
function m:refresh()
	local response = http_client.request {
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
function m:files()
	local response = http_client.request {
		url = "https://www.googleapis.com/drive/v3/files",
		method = "GET",
		headers = {Authorization = self.auth_token}
	}
	return json.parse(response.content)
end

-- Googleのインスタンス作成
function m.create(keys, refresh)
	local self = setmetatable(keys, {__index = m})
	if refresh == true then
		self:refresh()
	end
	return self
end

-- スプレッドシートを取得する
function spreadsheet:get()
	local response = http_client.request {
		url = "https://sheets.googleapis.com/v4/spreadsheets/"..self.spreadsheetid,
		method = "GET",
		headers = {Authorization = self.auth_token},
	}
	return json.parse(response.content)
end

-- シートのプロパティを取得する
function spreadsheet:sheet(title)
	local ss = self:get()
	for i,v in ipairs(ss.sheets) do
		if v.properties.title == title then
			return v.properties
		end
	end
end

-- スプレッドシートのセルの値を取得する
function spreadsheet:values(range, valueRenderOption)
	valueRenderOption = valueRenderOption or "UNFORMATTED_VALUE"
	local response = http_client.request {
		url = "https://sheets.googleapis.com/v4/spreadsheets/"..self.spreadsheetid.."/values/"..range,
		method = "GET",
		headers = {Authorization = self.auth_token},
		params = {
			valueRenderOption = valueRenderOption,
		},
	}
	return json.parse(response.content)
end

-- スプレッドシートのセルを更新する
function spreadsheet:update(requests)
	local response = http_client.request {
		url = "https://sheets.googleapis.com/v4/spreadsheets/"..self.spreadsheetid..":batchUpdate",
		method = "POST",
		headers = {Authorization = self.auth_token},
		data = json.stringify({requests = requests}),
	}
	return json.parse(response.content)
end

-- スプレッドシートのセルを全てクリアする
function spreadsheet:clear(sheetname)
	local sheet = self:sheet(sheetname)
	self:update {{
		repeatCell = {
			range = {
				sheetId = sheet.sheetId,
				startRowIndex = 0,
				startColumnIndex = 0,
				endRowIndex = sheet.gridProperties.rowCount,
				endColumnIndex = sheet.gridProperties.columnCount,
			},
			cell = {
				userEnteredValue = {stringValue = ""}
			},
			fields = "userEnteredValue",
		}
	}}
end

-- スプレッドシートマークアップ形式(ssml)を解析する
function parse_ssml(values, row, col)
	if not values or values[row] == nil then
		return "", row
	end

	local current = values[row][col] or ""
	if current == "" then
		return "", row
	end

	local right, rrow = parse_ssml(values, row, col+1)
	if right == "" then
		return current, row
	end

	local result = {}
	if current == "-" then
		table.insert(result, right)
		while values[rrow+1] and values[rrow+1][col] == "-" and values[rrow+1][col-1] == "" do
			row = rrow+1
			right, rrow = parse_ssml(values, row, col+1)
			table.insert(result, right)
		end
	else
		result[current] = right
		while values[rrow+1] and values[rrow+1][col] and values[rrow+1][col] ~= ""
				and (col == 1 or values[rrow+1][col-1] == "") do
			row = rrow+1
			current = values[row][col]
			right, rrow = parse_ssml(values, row, col+1)
			result[current] = right
		end
	end

	return result, rrow
end

-- スプレッドシートマークアップ形式データ(ssml)を読み込む
function spreadsheet.load_ssml(self, range)
	return parse_ssml(self:values(range).values, 1, 1)
end

-- スプレッドシートマークアップ形式データ(ssml)にフォーマットする
function format_ssml(data, rows, r, c)
	rows = rows or {}
	r = r or 1
	c = c or 1
	if type(data) ~= "table" then
		rows[r][c] = data
		return rows, r, c
	end

	local key = next(data)
	if not key then return rows, r-1, c end

	while #rows < r do table.insert(rows, {}) end
	local row = rows[r]
	while #row < c-1 do table.insert(row, "") end

	local val
	if #data > 0 then
		row[c] = "-"
		val = table.remove(data, key)
	else
		row[c] = key
		val = data[key]
		data[key] = nil
	end

	rows, r = format_ssml(val, rows, r, c+1)
	return unpack{format_ssml(data, rows, r+1, c)}
end

-- スプレッドシートマークアップ形式データ(ssml)を保存する
function spreadsheet:save_ssml(sheetname, data)
	data = json.parse(json.stringify(data))

	local rows = {}
	for k1,v1 in pairs(format_ssml(data)) do
		local row = {}
		for k2,v2 in pairs(v1) do
			local value = {}
			if type(v2) == 'number' then
				value = {numberValue = v2}
			else
				value = {stringValue = v2}
			end
			table.insert(row, {{userEnteredValue = value}})
		end
		table.insert(rows, {values=row})
	end

	local sheet = self:sheet(sheetname)
	self:update {{
		repeatCell = {
			range = {
				sheetId = sheet.sheetId,
				startRowIndex = 0,
				startColumnIndex = 0,
				endRowIndex = sheet.gridProperties.rowCount,
				endColumnIndex = sheet.gridProperties.columnCount,
			},
			cell = {
				userEnteredValue = {stringValue = ""}
			},
			fields = "userEnteredValue",
		}
	},{
		updateCells = {
			start = {
				sheetId = sheet.sheetId
			},
			rows = rows,
			fields = "userEnteredValue"
		}
	}}
end

-- スプレッドシートのインスタンス作成
function m:spreadsheet(spreadsheetid)
	local self = json.parse(json.stringify(self))
	self.spreadsheetid = spreadsheetid
	return setmetatable(self, {__index = spreadsheet})
end

return m
