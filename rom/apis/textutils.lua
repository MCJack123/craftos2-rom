local expect = dofile("rom/modules/main/cc/expect.lua")
local expect, field = expect.expect, expect.field

function slowWrite( sText, nRate )
    if nRate ~= nil and type( nRate ) ~= "number" then
        error( "bad argument #2 (expected number, got " .. type( nRate ) .. ")", 2 )
    end
    nRate = nRate or 20
    if nRate < 0 then
        error( "Rate must be positive", 2 )
    end
    local nSleep = 1 / nRate
        
    sText = tostring( sText )
    local x,y = term.getCursorPos()
    local len = string.len( sText )
    
    for n=1,len do
        term.setCursorPos( x, y )
        sleep( nSleep )
        local nLines = write( string.sub( sText, 1, n ) )
        local newX, newY = term.getCursorPos()
        y = newY - nLines
    end
end

function slowPrint( sText, nRate )
    slowWrite( sText, nRate )
    print()
end

function formatTime( nTime, bTwentyFourHour )
    if type( nTime ) ~= "number" then
        error( "bad argument #1 (expected number, got " .. type( nTime ) .. ")", 2 )
    end
    if bTwentyFourHour ~= nil and type( bTwentyFourHour ) ~= "boolean" then
        error( "bad argument #2 (expected boolean, got " .. type( bTwentyFourHour ) .. ")", 2 ) 
    end
    local sTOD = nil
    if not bTwentyFourHour then
        if nTime >= 12 then
            sTOD = "PM"
        else
            sTOD = "AM"
        end
        if nTime >= 13 then
            nTime = nTime - 12
        end
    end

    local nHour = math.floor(nTime)
    local nMinute = math.floor((nTime - nHour)*60)
    if sTOD then
        return string.format( "%d:%02d %s", nHour == 0 and 12 or nHour, nMinute, sTOD )
    else
        return string.format( "%d:%02d", nHour, nMinute )
    end
end

local function makePagedScroll( _term, _nFreeLines )
    local nativeScroll = _term.scroll
    local nFreeLines = _nFreeLines or 0
    return function( _n )
        for n=1,_n do
            nativeScroll( 1 )
            
            if nFreeLines <= 0 then
                local w,h = _term.getSize()
                _term.setCursorPos( 1, h )
                _term.write( "Press any key to continue" )
                os.pullEvent( "key" )
                _term.clearLine()
                _term.setCursorPos( 1, h )
            else
                nFreeLines = nFreeLines - 1
            end
        end
    end
end

function pagedPrint( _sText, _nFreeLines )
    if _nFreeLines ~= nil and type( _nFreeLines ) ~= "number" then
        error( "bad argument #2 (expected number, got " .. type( _nFreeLines ) .. ")", 2 ) 
    end
    -- Setup a redirector
    local oldTerm = term.current()
    local newTerm = {}
    for k,v in pairs( oldTerm ) do
        newTerm[k] = v
    end
    newTerm.scroll = makePagedScroll( oldTerm, _nFreeLines )
    term.redirect( newTerm )

    -- Print the text
    local result
    local ok, err = pcall( function()
        if _sText ~= nil then
            result = print( _sText )
        else
            result = print()
        end
    end )

    -- Removed the redirector
    term.redirect( oldTerm )

    -- Propogate errors
    if not ok then
        error( err, 0 )
    end
    return result
end

local function npairs(t)
    if t.n == nil then error("no number field", 2) end
    local i = 0
    return function()
        i = i + 1
        if i > t.n then return nil
        else return i, t[i] end
    end
end

local function tabulateCommon( bPaged, ... )
    local tAll = table.pack( ... )
    for k,v in npairs( tAll ) do
        if type( v ) ~= "number" and type( v ) ~= "table" then
            error( "bad argument #"..k.." (expected number or table, got " .. type( v ) .. ")", 3 ) 
        end
    end
    
    local w,h = term.getSize()
    local nMaxLen = w / 8
    for n, t in npairs( tAll ) do
        if type(t) == "table" then
            for n, sItem in pairs(t) do
                nMaxLen = math.max( string.len( sItem ) + 1, nMaxLen )
            end
        end
    end
    local nCols = math.floor( w / nMaxLen )
    local nLines = 0
    local function newLine()
        if bPaged and nLines >= (h-3) then
            pagedPrint()
        else
            print()
        end
        nLines = nLines + 1
    end
    
    local function drawCols( _t )
        local nCol = 1
        for n, s in ipairs( _t ) do
            if nCol > nCols then
                nCol = 1
                newLine()
            end

            local cx, cy = term.getCursorPos()
            cx = 1 + ((nCol - 1) * nMaxLen)
            term.setCursorPos( cx, cy )
            term.write( s )

            nCol = nCol + 1      
        end
        print()
    end
    for n, t in npairs( tAll ) do
        if type(t) == "table" then
            if #t > 0 then
                drawCols( t )
            end
        elseif type(t) == "number" then
            term.setTextColor( t )
        end
    end    
end

function tabulate( ... )
    tabulateCommon( false, ... )
end

function pagedTabulate( ... )
    tabulateCommon( true, ... )
end

local g_tLuaKeywords = {
    [ "and" ] = true,
    [ "break" ] = true,
    [ "do" ] = true,
    [ "else" ] = true,
    [ "elseif" ] = true,
    [ "end" ] = true,
    [ "false" ] = true,
    [ "for" ] = true,
    [ "function" ] = true,
    [ "if" ] = true,
    [ "in" ] = true,
    [ "local" ] = true,
    [ "nil" ] = true,
    [ "not" ] = true,
    [ "or" ] = true,
    [ "repeat" ] = true,
    [ "return" ] = true,
    [ "then" ] = true,
    [ "true" ] = true,
    [ "until" ] = true,
    [ "while" ] = true,
}

local function serializeImpl( t, tTracking, sIndent )
    local sType = type(t)
    if sType == "table" then
        if tTracking[t] ~= nil then
            error( "Cannot serialize table with recursive entries", 0 )
        end
        tTracking[t] = true

        if next(t) == nil then
            -- Empty tables are simple
            return "{}"
        else
            -- Other tables take more work
            local sResult = "{\n"
            local sSubIndent = sIndent .. "  "
            local tSeen = {}
            for k,v in ipairs(t) do
                tSeen[k] = true
                sResult = sResult .. sSubIndent .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
            end
            for k,v in pairs(t) do
                if not tSeen[k] then
                    local sEntry
                    if type(k) == "string" and not g_tLuaKeywords[k] and string.match( k, "^[%a_][%a%d_]*$" ) then
                        sEntry = k .. " = " .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
                    else
                        sEntry = "[ " .. serializeImpl( k, tTracking, sSubIndent ) .. " ] = " .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
                    end
                    sResult = sResult .. sSubIndent .. sEntry
                end
            end
            sResult = sResult .. sIndent .. "}"
            return sResult
        end
        
    elseif sType == "string" then
        return string.format( "%q", t )
    
    elseif sType == "number" or sType == "boolean" or sType == "nil" then
        return tostring(t)
        
    else
        error( "Cannot serialize type "..sType, 0 )
        
    end
end

local function mk_tbl(str, name)
    local msg = "attempt to mutate textutils." .. name
    return setmetatable({}, {
        __newindex = function() error(msg, 2) end,
        __tostring = function() return str end,
    })
end

empty_json_array = mk_tbl("[]", "empty_json_array")
json_null = mk_tbl("null", "json_null")

local serializeJSONString
do
    local function hexify(c)
        return ("\\u00%02X"):format(c:byte())
    end

    local map = {
        ["\""] = "\\\"",
        ["\\"] = "\\\\",
        ["\b"] = "\\b",
        ["\f"] = "\\f",
        ["\n"] = "\\n",
        ["\r"] = "\\r",
        ["\t"] = "\\t",
    }
    for i = 0, 0x1f do
        local c = string.char(i)
        if map[c] == nil then map[c] = hexify(c) end
    end

    serializeJSONString = function(s)
        return ('"%s"'):format(s:gsub("[%z\1-\x1f\"\\]", map):gsub("[\x7f-\xff]", hexify))
    end
end

local function serializeJSONImpl( t, tTracking, bNBTStyle )
    local sType = type(t)
    if t == empty_json_array then
        return "[]"

    elseif t == json_null then
        return "null"

    elseif sType == "table" then
        if tTracking[t] ~= nil then
            error( "Cannot serialize table with recursive entries", 0 )
        end
        tTracking[t] = true

        if next(t) == nil then
            -- Empty tables are simple
            return "{}"
        else
            -- Other tables take more work
            local sObjectResult = "{"
            local sArrayResult = "["
            local nObjectSize = 0
            local nArraySize = 0
            for k,v in pairs(t) do
                if type(k) == "string" then
                    local sEntry
                    if bNBTStyle then
                        sEntry = tostring(k) .. ":" .. serializeJSONImpl( v, tTracking, bNBTStyle )
                    else
                        sEntry = serializeJSONString( k ) .. ":" .. serializeJSONImpl( v, tTracking, bNBTStyle )
                    end
                    if nObjectSize == 0 then
                        sObjectResult = sObjectResult .. sEntry
                    else
                        sObjectResult = sObjectResult .. "," .. sEntry
                    end
                    nObjectSize = nObjectSize + 1
                end
            end
            for n,v in ipairs(t) do
                local sEntry = serializeJSONImpl( v, tTracking, bNBTStyle )
                if nArraySize == 0 then
                    sArrayResult = sArrayResult .. sEntry
                else
                    sArrayResult = sArrayResult .. "," .. sEntry
                end
                nArraySize = nArraySize + 1
            end
            sObjectResult = sObjectResult .. "}"
            sArrayResult = sArrayResult .. "]"
            if nObjectSize > 0 or nArraySize == 0 then
                return sObjectResult
            else
                return sArrayResult
            end
        end

    elseif sType == "string" then
        return serializeJSONString( t )

    elseif sType == "number" or sType == "boolean" then
        return tostring(t)

    else
        error( "Cannot serialize type "..sType, 0 )

    end
end

local unserialise_json
do
    local sub, find, match, concat, tonumber = string.sub, string.find, string.match, table.concat, tonumber

    --- Skip any whitespace
    local function skip(str, pos)
        local _, last = find(str, "^[ \n\r\v]+", pos)
        if last then return last + 1 else return pos end
    end

    local escapes = {
        ["b"] = '\b', ["f"] = '\f', ["n"] = '\n', ["r"] = '\r', ["t"] = '\t',
        ["\""] = "\"", ["/"] = "/", ["\\"] = "\\",
    }

    local mt = {}

    local function error_at(pos, msg, ...)
        if select('#', ...) > 0 then msg = msg:format(...) end
        error(setmetatable({ pos = pos, msg = msg }, mt))
    end

    local function expected(pos, actual, exp)
        if actual == "" then actual = "end of input" else actual = ("%q"):format(actual) end
        error_at(pos, "Unexpected %s, expected %s.", actual, exp)
    end

    local function parse_string(str, pos)
        local buf, n = {}, 1

        while true do
            local c = sub(str, pos, pos)
            if c == "" then error_at(pos, "Unexpected end of input, expected '\"'.") end
            if c == '"' then break end

            if c == '\\' then
                -- Handle the various escapes
                c = sub(str, pos + 1, pos + 1)
                if c == "" then error_at(pos, "Unexpected end of input, expected escape sequence.") end

                if c == "u" then
                    local num_str = match(str, "^%x%x%x%x", pos + 2)
                    if not num_str then error_at(pos, "Malformed unicode escape %q.", sub(str, pos + 2, pos + 5)) end
                    buf[n], n, pos = utf8.char(tonumber(num_str, 16)), n + 1, pos + 6
                else
                    local unesc = escapes[c]
                    if not unesc then error_at(pos + 1, "Unknown escape character %q.", escapes[c]) end
                    buf[n], n, pos = unesc, n + 1, pos + 2
                end
            elseif c >= '\x20' then
                buf[n], n, pos = c, n + 1, pos + 1
            else
                error_at(pos + 1, "Unescaped whitespace %q.", c)
            end
        end

        return concat(buf, "", 1, n - 1), pos + 1
    end

    local valid = { b = true, B = true, s = true, S = true, l = true, L = true, f = true, F = true, d = true, D = true }
    local function parse_number(str, pos, opts)
        local _, last, num_str = find(str, '^(-?%d+%.?%d*[eE]?[+-]?%d*)', pos)
        local val = tonumber(num_str)
        if not val then error_at(pos, "Malformed number %q.", num_str) end

        if opts.nbt_style and valid[sub(str, pos + 1, pos + 1)] then return val, last + 2 end

        return val, last + 1
    end

    local function parse_ident(str, pos)
        local _, last, val = find(str, '^([%a][%w_]*)', pos)
        return val, last + 1
    end

    local function decode_impl(str, pos, opts)
        local c = sub(str, pos, pos)
        if c == '"' then return parse_string(str, pos + 1)
        elseif c == "-" or c >= "0" and c <= "9" then return parse_number(str, pos, opts)
        elseif c == "t" then
            if sub(str, pos + 1, pos + 3) == "rue" then return true, pos + 4 end
        elseif c == 'f' then
            if sub(str, pos + 1, pos + 4) == "alse" then return false, pos + 5 end
        elseif c == 'n' then
            if sub(str, pos + 1, pos + 3) == "ull" then
                if opts.parse_null then
                    return json_null, pos + 4
                else
                    return nil, pos + 4
                end
            end
        elseif c == "{" then
            local obj = {}

            pos = skip(str, pos + 1)
            c = sub(str, pos, pos)

            if c == "" then return error_at(pos, "Unexpected end of input, expected '}'.") end
            if c == "}" then return obj, pos + 1 end

            while true do
                local key, value
                if c == "\"" then key, pos = parse_string(str, pos + 1)
                elseif opts.nbt_style then key, pos = parse_ident(str, pos)
                else return expected(pos, c, "object key")
                end

                pos = skip(str, pos)

                c = sub(str, pos, pos)
                if c ~= ":" then return expected(pos, c, "':'") end

                value, pos = decode_impl(str, skip(str, pos + 1), opts)
                obj[key] = value

                -- Consume the next delimiter
                pos = skip(str, pos)
                c = sub(str, pos, pos)
                if c == "}" then break
                elseif c == "," then pos = skip(str, pos + 1)
                else return expected(pos, c, "',' or '}'")
                end

                c = sub(str, pos, pos)
            end

            return obj, pos + 1

        elseif c == "[" then
            local arr, n = {}, 1

            pos = skip(str, pos + 1)
            c = sub(str, pos, pos)

            if c == "" then return expected(pos, c, "']'") end
            if c == "]" then return empty_json_array, pos + 1 end

            while true do
                n, arr[n], pos = n + 1, decode_impl(str, pos, opts)

                -- Consume the next delimiter
                pos = skip(str, pos)
                c = sub(str, pos, pos)
                if c == "]" then break
                elseif c == "," then pos = skip(str, pos + 1)
                else return expected(pos, c, "',' or ']'")
                end
            end

            return arr, pos + 1
        elseif c == "" then error_at(pos, 'Unexpected end of input.')
        end

        error_at(pos, "Unexpected character %q.", c)
    end

    --- Converts a serialised JSON string back into a reassembled Lua object.
    --
    -- This may be used with @{textutils.serializeJSON}, or when communicating
    -- with command blocks or web APIs.
    --
    -- @tparam string s The serialised string to deserialise.
    -- @tparam[opt] { nbt_style? = boolean, parse_null? = boolean } options
    -- Options which control how this JSON object is parsed.
    --
    --  - `nbt_style`: When true, this will accept [stringified NBT][nbt] strings,
    --    as produced by many commands.
    --  - `parse_null`: When true, `null` will be parsed as @{json_null}, rather
    --    than `nil`.
    --
    --  [nbt]: https://minecraft.gamepedia.com/NBT_format
    -- @return[1] The deserialised object
    -- @treturn[2] nil If the object could not be deserialised.
    -- @treturn string A message describing why the JSON string is invalid.
    unserialise_json = function(s, options)
        expect(1, s, "string")
        expect(2, options, "table", "nil")

        if options then
            field(options, "nbt_style", "boolean", "nil")
            field(options, "nbt_style", "boolean", "nil")
        else
            options = {}
        end

        local ok, res, pos = pcall(decode_impl, s, skip(s, 1), options)
        if not ok then
            if type(res) == "table" and getmetatable(res) == mt then
                return nil, ("Malformed JSON at position %d: %s"):format(res.pos, res.msg)
            end

            error(res, 0)
        end

        pos = skip(s, pos)
        if pos <= #s then
            return nil, ("Malformed JSON at position %d: Unexpected trailing character %q."):format(pos, sub(s, pos, pos))
        end
        return res

    end
end

function serialize( t )
    local tTracking = {}
    return serializeImpl( t, tTracking, "" )
end

function unserialize( s )
    if type( s ) ~= "string" then
        error( "bad argument #1 (expected string, got " .. type( s ) .. ")", 2 )
    end
    local func = load( "return "..s, "unserialize", "t", {} )
    if func then
        local ok, result = pcall( func )
        if ok then
            return result
        end
    end
    return nil
end

function serializeJSON( t, bNBTStyle )
    if type( t ) ~= "table" and type( t ) ~= "string" and type( t ) ~= "number" and type( t ) ~= "boolean" then
        error( "bad argument #1 (expected table, string, number or boolean, got " .. type( t ) .. ")", 2 )
    end
    if bNBTStyle ~= nil and type( bNBTStyle ) ~= "boolean" then
        error( "bad argument #2 (expected boolean, got " .. type( bNBTStyle ) .. ")", 2 )
    end
    local tTracking = {}
    return serializeJSONImpl( t, tTracking, bNBTStyle or false )
end

unserializeJSON = unserialise_json

function urlEncode( str )
    if type( str ) ~= "string" then
        error( "bad argument #1 (expected string, got " .. type( str ) .. ")", 2 )
    end
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^A-Za-z0-9 %-%_%.])", function(c)
            local n = string.byte(c)
            if n < 128 then
                -- ASCII
                return string.format("%%%02X", n)
            else
                -- Non-ASCII (encode as UTF-8)
                return
                    string.format("%%%02X", 192 + bit32.band( bit32.arshift(n,6), 31 ) ) ..
                    string.format("%%%02X", 128 + bit32.band( n, 63 ) )
            end
        end )
        str = string.gsub(str, " ", "+")
    end
    return str    
end

local tEmpty = {}
function complete( sSearchText, tSearchTable )
    if type( sSearchText ) ~= "string" then
        error( "bad argument #1 (expected string, got " .. type( sSearchText ) .. ")", 2 )
    end
    if tSearchTable ~= nil and type( tSearchTable ) ~= "table" then
        error( "bad argument #2 (expected table, got " .. type( tSearchTable ) .. ")", 2 )
    end

    if g_tLuaKeywords[sSearchText] then return tEmpty end
    local nStart = 1
    local nDot = string.find( sSearchText, ".", nStart, true )
    local tTable = tSearchTable or _ENV
    while nDot do
        local sPart = string.sub( sSearchText, nStart, nDot - 1 )
        local value = tTable[ sPart ]
        if type( value ) == "table" then
            tTable = value
            nStart = nDot + 1
            nDot = string.find( sSearchText, ".", nStart, true )
        else
            return tEmpty
        end
    end
    local nColon = string.find( sSearchText, ":", nStart, true )
    if nColon then
        local sPart = string.sub( sSearchText, nStart, nColon - 1 )
        local value = tTable[ sPart ]
        if type( value ) == "table" then
            tTable = value
            nStart = nColon + 1
        else
            return tEmpty
        end
    end
    
    local sPart = string.sub( sSearchText, nStart )
    local nPartLength = string.len( sPart )

    local tResults = {}
    local tSeen = {}
    while tTable do
        for k,v in pairs( tTable ) do
            if not tSeen[k] and type(k) == "string" then
                if string.find( k, sPart, 1, true ) == 1 then
                    if not g_tLuaKeywords[k] and string.match( k, "^[%a_][%a%d_]*$" ) then
                        local sResult = string.sub( k, nPartLength + 1 )
                        if nColon then
                            if type(v) == "function" then
                                table.insert( tResults, sResult .. "(" )
                            elseif type(v) == "table" then
                                local tMetatable = getmetatable( v )
                                if tMetatable and ( type( tMetatable.__call ) == "function" or  type( tMetatable.__call ) == "table" ) then
                                    table.insert( tResults, sResult .. "(" )
                                end
                            end
                        else
                            if type(v) == "function" then
                                sResult = sResult .. "("
                            elseif type(v) == "table" and next(v) ~= nil then
                                sResult = sResult .. "."
                            end
                            table.insert( tResults, sResult )
                        end
                    end
                end
            end
            tSeen[k] = true
        end
        local tMetatable = getmetatable( tTable )
        if tMetatable and type( tMetatable.__index ) == "table" then
            tTable = tMetatable.__index
        else
            tTable = nil
        end
    end

    table.sort( tResults )
    return tResults
end

-- GB versions
serialise = serialize
unserialise = unserialize
serialiseJSON = serializeJSON
unserialiseJSON = unserialise_json
