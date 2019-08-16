
local native = (term.native and term.native()) or term
local redirectTarget = native

local function wrap( _sFunction )
	return function( ... )
        if redirectTarget[_sFunction] == nil then error("Target missing function " .. _sFunction) end
		return redirectTarget[ _sFunction ]( ... )
	end
end

local mainTerm = term
local term = {}

native.redirect = function( target )
    if type( target ) ~= "table" then
        error( "bad argument #1 (expected table, got " .. type( target ) .. ")", 2 ) 
    end
    if target == term then
        error( "term is not a recommended redirect target, try term.current() instead", 2 )
    end
    --traceback("redirecting")
	for k,v in pairs( native ) do
		if type( k ) == "string" and type( v ) == "function" and k ~= "native" and k ~= "current" and k ~= "redirect" then
			if type( target[k] ) ~= "function" then
				target[k] = function()
					error( "Redirect object is missing method "..k..".", 2 )
				end
			end
		end
	end
	target.native = redirectTarget.native
	target.current = redirectTarget.current
	target.redirect = redirectTarget.redirect
	local oldRedirectTarget = redirectTarget
	redirectTarget = target
	return oldRedirectTarget
end

native.current = function()
    return redirectTarget
end

native.native = function()
    -- NOTE: please don't use this function unless you have to.
    -- If you're running in a redirected or multitasked enviorment, term.native() will NOT be
    -- the current terminal when your program starts up. It is far better to use term.current()
    return native
end
--[[
native._swChar = function(x, y, b, f, c)
	if not mainTerm.getGraphicsMode() then error("cannot use software fonts in text mode", 2) end
	local cv = term.currentFont[string.byte(c)]
	for py = 0, term.currentFont.height-1 do
		for px = 0, term.currentFont.width do
			--os.debug(tostring(f))
			if bit.band(cv[py], bit.blshift(1, px)) then term.setPixel(x + px, y + py, f)
			else term.setPixel(x + px, y + py, b) end
		end
	end
end

native._swWrite = function(text)
	if not mainTerm.getGraphicsMode() then error("cannot use software fonts in text mode", 2) end
	local w, h = term.getSize()
	if term.currentFont.yPos > h * 9 then return end
	for s in string.gmatch(text, ".") do
		if term.currentFont.xPos + term.currentFont.width > w * 6 then
			term.currentFont.xPos = 0
			term.currentFont.yPos = term.currentFont.yPos + term.currentFont.height
			if term.currentFont.yPos > h * 9 then return end
		end
		term._swChar(term.currentFont.xPos, term.currentFont.yPos, term.getBackgroundColor(), term.getTextColor(), s)
	end
end

native._swBlit = function(text, bg, fg)
	if not mainTerm.getGraphicsMode() then error("cannot use software fonts in text mode", 2) end
	local w, h = term.getSize()
	if term.currentFont.yPos > h * 9 then return end
	for i = 1, string.len(text) + 1 do
		if term.currentFont.xPos + term.currentFont.width > w * 6 then
			term.currentFont.xPos = 0
			term.currentFont.yPos = term.currentFont.yPos + term.currentFont.height
			if term.currentFont.yPos > h * 9 then return end
		end
		local pbg = bit.blshift(1, string.find("0123456789abcdef", bg[i]) - 1)
		local pfg = bit.blshift(1, string.find("0123456789abcdef", fg[i]) - 1)
		term._swChar(term.currentFont.xPos, term.currentFont.yPos, pbg, pfg, text[i])
	end
end

native._swSetCursorPos = function(x, y)
	if not mainTerm.getGraphicsMode() then error("cannot use software fonts in text mode", 2) end
	term.currentFont.xPos = x
	term.currentFont.yPos = y
end

native._swGetCursorPos = function()
	if not mainTerm.getGraphicsMode() then error("cannot use software fonts in text mode", 2) end
	return term.currentFont.xPos, term.currentFont.yPos
end

native.setSoftwareFont = function(font)
	if not mainTerm.getGraphicsMode() then error("cannot use software fonts in text mode", 2) end
	if type(font.width) ~= "number" or type(font.height) ~= "number" or font.width == 0 or font.height == 0 then
		error("invalid font (missing size)", 2)
	end
	for i = 0,256 do if type(font[i]) ~= "table" then error("invalid font (bad character)", 2) end end
	if font.xPos == nil then font.xPos = 0 end
	if font.yPos == nil then font.yPos = 0 end
	term.currentFont = font
end

native.getSoftwareFont = function()
	if not mainTerm.getGraphicsMode() then error("cannot use software fonts in text mode", 2) end
	return term.currentFont
end

native.getNativeFont = function()
	if not mainTerm.getGraphicsMode() then error("cannot use software fonts in text mode", 2) end
	return term.defaultFont
end

native.write = function(text)
	if mainTerm.getGraphicsMode() then
		term._swWrite(text)
	else
		term._hwWrite(text)
	end
end

native.blit = function(text, bg, fg)
	if mainTerm.getGraphicsMode() then
		term._swBlit(text, bg, fg)
	else
		term._hwBlit(text, bg, fg)
	end
end

native.setCursorPos = function(x, y)
	if mainTerm.getGraphicsMode() then
		term._swSetCursorPos(x, y)
	else
		term._hwSetCursorPos(x, y)
	end
end

native.getCursorPos = function()
	if native.getGraphicsMode() then
		return term._swGetCursorPos()
	else
		return term._hwGetCursorPos()
	end
end
]]--
mainTerm.defaultFont = {}
mainTerm.currentFont = {}
mainTerm.loadFontFile = function()
    if fs.exists("rom/fonts/term_font.ccfnt") then
        local font_file = fs.open("rom/fonts/term_font.ccfnt", "r")
        if font_file ~= nil then
            --os.debug("Got font")
            local contents = font_file.readAll()
            --os.debug(contents)
            mainTerm.defaultFont = textutils.unserialize(contents)
            font_file.close()
            if mainTerm.defaultFont == nil then error("Font file is in incorrect format") end
        else error("Could not open font file") end
    else error("Could not find font file") end
    mainTerm.currentFont = mainTerm.defaultFont
end

native.redirect(native)

for k,v in pairs( native ) do
	if type( k ) == "string" and type( v ) == "function" then
		if term[k] == nil then
			term[k] = wrap( k )
		end
	end
end
	
local env = _ENV
for k,v in pairs( term ) do
	env[k] = v
end
