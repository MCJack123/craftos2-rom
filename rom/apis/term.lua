
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
	if target.setGraphicsMode == nil then target.setGraphicsMode = native.setGraphicsMode end
	if target.getGraphicsMode == nil then target.getGraphicsMode = native.getGraphicsMode end
	if target.setPixel == nil then target.setPixel = native.setPixel end
	if target.getPixel == nil then target.getPixel = native.getPixel end
	if target.drawPixels == nil then target.drawPixels = native.drawPixels end
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
