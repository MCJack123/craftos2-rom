local tArgs = { ... }
if #tArgs < 2 then
    print( "Usage: rename <source> <destination>" )
    return
end

local sSource = shell.resolve( tArgs[1] )
local sDest = shell.resolve( tArgs[2] )

if not fs.exists( sSource ) then
    printError( "No matching files" )
elseif fs.isDriveRoot(sSource) then
    printError("Can't rename mounts")
    return
elseif fs.isReadOnly(sSource) then
    printError("Source is read-only")
    return
elseif fs.exists( sDest ) then
    printError( "Destination exists" )
elseif fs.isReadOnly( sDest ) then
    printError( "Destination is read-only" )
else
    fs.move( sSource, sDest )
end
