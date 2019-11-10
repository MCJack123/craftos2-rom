
local function printUsage()
    print( "Usage:" )
    print( "wget <url> <filename>" )
    print( "wget run <url> [args...]" )
end
 
local tArgs = { ... }
if #tArgs < 2 then
    printUsage()
    return
end
 
if not http then
    printError( "wget requires http API" )
    printError( "Set http_enable to true in ComputerCraft.cfg" )
    return
end
 
local function get( sUrl )
    write( "Connecting to " .. sUrl .. "... " )

    local ok, err = http.checkURL( sUrl )
    if not ok then
        print( "Failed." )
        if err then
            printError( err )
        end
        return nil
    end

    local response = http.get( sUrl , nil , true )
    if not response then
        print( "Failed." )
        return nil
    end

    print( "Success." )

    local sResponse = response.readAll()
    response.close()
    return sResponse
end

if tArgs[2] == "run" then
    local sUrl = tArgs[2]
    local res = get( sUrl )
    if not res then
        printError( "Failed to download" )
        return
    end
    local func, err = load( res, fs.getName( sUrl ), "t", _ENV )
    if not func then
        printError( err )
        return
    end

    local ok, err = pcall( func, table.unpack( tArgs, 3 ) )
    if not ok then
        printError( err )
    end
else
    -- Determine file to download
    local sUrl = tArgs[1]
    local sFile = tArgs[2]
    local sPath = shell.resolve( sFile )
    if fs.exists( sPath ) then
        print( "File already exists" )
        return
    end

    -- Do the get
    local res = get( sUrl )
    if res then
        local file = fs.open( sPath, "wb" )
        file.write( res )
        file.close()

        print( "Downloaded as "..sFile )
    else
        printError( "Failed to download" )
        return
    end
end