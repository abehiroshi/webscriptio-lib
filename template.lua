-- lustacheをtableで使う

local m = {}

-- lustacheを利用できるようにする
function m.use(lustache)
	setmetatable(m, {__index = lustache})
	return m
end

-- テンプレートにパラメータを適用する
function m.apply(template, args)
	local t
	if type(template) == 'table' then
		t = json.stringify(template)
	else
		t = template
	end
	return json.parse(m:render(t, args))
end

return m
