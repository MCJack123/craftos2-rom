
local tArgs = { ... }
if #tArgs < 1 then
    print( "Usage: rm <path...>" )
    return
end

for i = 1, #tArgs do
    local sPath = shell.resolve( tArgs[i] )
    local tFiles = fs.find( sPath )
    if #tFiles > 0 then
        for _, file in ipairs( tFiles ) do
            if fs.isReadOnly(file) then
                printError("Cannot delete read-only file /" .. file)
            elseif fs.isDriveRoot(file) then
                printError("Cannot delete mount /" .. file)
                if fs.isDir(file) then
                    print("To delete its contents run rm /" .. fs.combine(file, "*") .. ", or to unmount it run unmount /" .. file)
                end
            else
                local ok, err = pcall(fs.delete, file)
                if not ok then
                    printError((err:gsub("^pcall: ", "")))
                end
            end
        end
    else
        printError( "No matching files" )
    end
end
