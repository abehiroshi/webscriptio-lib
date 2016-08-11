-- Google API

local m = {}
local spreadsheet = {}

-- アクセストークンを再取得する
function m:refresh()
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
function m:files()
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

-- スプレッドシートを取得する
function spreadsheet:get()
	local response = http.request {
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
function spreadsheet:values(range)
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
	local rows = {}
	for k1,v1 in pairs(format_ssml(data)) do
		local row = {}
		for k2,v2 in pairs(v1) do
			table.insert(row, {{userEnteredValue = {stringValue = v2}}})
		end
		table.insert(rows, {values=row})
	end

	local sheet = self:sheet(sheetname)
	self:update {
		start = {
			sheetId = sheet.sheetId
		},
		rows = rows,
		fields = "userEnteredValue"
	}
end

-- スプレッドシートのセルの値を更新する
function spreadsheet:update(updateCells)
	local response = http.request {
		url = "https://sheets.googleapis.com/v4/spreadsheets/"..self.spreadsheetid..":batchUpdate",
		method = "POST",
		headers = {Authorization = self.auth_token},
		data = json.stringify({requests = {{updateCells = updateCells}}}),
	}
	return json.parse(response.content)
end

-- スプレッドシートのインスタンス作成
function m:spreadsheet(spreadsheetid)
	local self = json.parse(json.stringify(self))
	self.spreadsheet = spreadsheet
	return setmetatable(self, {__index = spreadsheet})
end

return m
