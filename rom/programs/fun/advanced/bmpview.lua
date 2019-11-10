if term.getGraphicsMode == nil then error("This requires CraftOS-PC v1.2 or later.") end

function term.setHex(color, hex)
    term.setPaletteColor(color, bit.brshift(bit.band(hex, 0xFF0000), 16) / 256, bit.brshift(bit.band(hex, 0x00FF00), 8) / 256, bit.band(hex, 0x0000FF) / 256)
end

function term.restorePalette()
    term.setHex(colors.black, 0x191919)
    term.setHex(colors.blue, 0x3366CC)
    term.setHex(colors.green, 0x57A64E)
    term.setHex(colors.cyan, 0x4C99B2)
    term.setHex(colors.red, 0xCC4C4C)
    term.setHex(colors.purple, 0xB266E5)
    term.setHex(colors.brown, 0x7F664C)
    term.setHex(colors.lightGray, 0x999999)
    term.setHex(colors.gray, 0x4C4C4C)
    term.setHex(colors.lightBlue, 0x99B2F2)
    term.setHex(colors.lime, 0x7FCC19)
    term.setHex(colors.pink, 0xF2B2CC)
    term.setHex(colors.orange, 0xF2B233)
    term.setHex(colors.magenta, 0xE57FD8)
    term.setHex(colors.yellow, 0xDEDE6C)
    term.setHex(colors.white, 0xF0F0F0)
end

origerror = error
error = function(...)
    term.setGraphicsMode(false)
    origerror(...)
end

local args = { ... }
if #args < 1 then error("Usage: display_image <file.ccbmp>") end

if not fs.exists(args[1]) then error("File doesn't exist") end
local file = fs.open(args[1], "rb")
if file == nil then error("Could not open file") end
if string.char(file.read(), file.read(), file.read(), file.read()) ~= "cbmp" then error("File is not a CCBMP") end

local width = bit.bor(file.read(), bit.blshift(file.read(), 8))
local height = bit.bor(file.read(), bit.blshift(file.read(), 8))
local y = 0
local b = 0
local low = false
local offset = 8
term.setGraphicsMode(true)
while y < height do
    local x = 0
    while x < width do
        if low then
            term.setPixel(x, y, bit.blshift(1, bit.band(b, 0x0F)))
            low = false
        else
            b = file.read()
            offset = offset + 1
            term.setPixel(x, y, bit.blshift(1, bit.brshift(bit.band(b, 0xF0), 4)))
            low = true
        end
        x = x + 1
    end
    y = y + 1
end

local paletteSize = file.read()
local c = 0
while c < paletteSize do
    offset = offset + 3
    term.setPaletteColor(bit.blshift(1, c), file.read() / 256, file.read() / 256, file.read() / 256)
    c = c + 1
end
file.close()

os.pullEvent("char")

term.setGraphicsMode(false)
term.restorePalette()