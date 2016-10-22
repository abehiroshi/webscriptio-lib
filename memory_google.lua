-- memoryをgoogle spreadsheetと連携

local logger = (require 'logger').get('memory_google')
local memory = require 'abehiroshi/webscriptio-lib/memory'
local google = require 'abehiroshi/webscriptio-lib/google'

local m = {}

-- Google SpreadSheetから読み込み
function m:load(sheetname)
    logger.info('load', sheetname)
    self.sheetname = sheetname

    local g = google.create(self.google.keys, true)
    local sheet = g:spreadsheet(self.google.spreadsheetid)
    self.memory = memory.load(sheetname, sheet:load_ssml(sheetname))

    if logger.is_debug() then logger.debug('load dump', self.memory:dump()) end

    if self.name == sheetname and not self.memory.data.google then
        self.memory.data.google = self.google
        self:save()
    end

    return self.memory
end

function m:save()
    if not self.sheetname then return end
    logger.info('save', self.sheetname)

    local dump = self.memory:dump()
    sheet:save_ssml(self.sheetname, dump)

    logger.debug('save dump', dump)
end

function m.create(name, google_config)
    logger.info('create', name, google_config)
    return setmetatable(
        {
            name = name,
            google = google_config or memory.load(name).data.google,
        },
        {__index = m}
    )
end

return m