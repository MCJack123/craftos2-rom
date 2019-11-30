
local tArgs = { ... }
if #tArgs < 1 then
    print( "Usage: rm <path>" )
    return
end

local sPath = shell.resolve( tArgs[1] )
local tFiles = fs.find( sPath )
if #tFiles > 0 then
    for n,sFile in ipairs( tFiles ) do
        local ok, err = pcall(fs.delete, file)
        if not ok then
            printError(string.gsub(err, "^pcall: ", ""))
        end
    end
else
    printError( "No matching files" )
end
