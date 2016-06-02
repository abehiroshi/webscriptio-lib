-- lustacheをtableで使う

local lustache = require 'lustache'

local m = {}

-- テンプレートにパラメータを適用する
function m.apply(template, args)
	local t
	if type(template) == 'table' then
		t = json.stringify(template)
	else
		t = template
	end
	return json.parse(lustache:render(t, args))
end

return m
