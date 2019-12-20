
local tArgs = { ... }
if #tArgs < 1 then
    print( "Usage: rm <path...>" )
    return
end

for i = 1, #tArgs do
    local sPath = shell.resolve( tArgs[i] )
    local tFiles = fs.find( sPath )
    if #tFiles > 0 then
        for n,sFile in ipairs( tFiles ) do
            local ok, err = pcall(fs.delete, sFile)
            if not ok then
                printError(string.gsub(err, "^pcall: ", ""))
            end
        end
    else
        printError( "No matching files" )
    end
end
