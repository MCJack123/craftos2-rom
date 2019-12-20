local tArgs = { ... }
if #tArgs < 1 then
    print( "Usage: mkdir <path...>" )
    return
end

for i = 1, #tArgs do
    local sNewDir = shell.resolve( tArgs[i] )

    if fs.exists( sNewDir ) and not fs.isDir(sNewDir) then
        printError( "Destination exists" )
        return
    end

    fs.makeDir( sNewDir )
end
