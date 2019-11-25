
-- Setup paths
local sPath = ".:/rom/programs"
if term.isColor() then
    sPath = sPath..":/rom/programs/advanced"
end
if turtle then
    sPath = sPath..":/rom/programs/turtle"
else
    sPath = sPath..":/rom/programs/rednet:/rom/programs/fun"
    if term.isColor() then
        sPath = sPath..":/rom/programs/fun/advanced"
    end
end
if pocket then
    sPath = sPath..":/rom/programs/pocket"
end
if commands then
    sPath = sPath..":/rom/programs/command"
end
if http then
    sPath = sPath..":/rom/programs/http"
end
shell.setPath( sPath )
help.setPath( "/rom/help" )

-- Setup aliases
shell.setAlias( "ls", "list" )
shell.setAlias( "dir", "list" )
shell.setAlias( "cp", "copy" )
shell.setAlias( "mv", "move" )
shell.setAlias( "rm", "delete" )
shell.setAlias( "clr", "clear" )
shell.setAlias( "rs", "redstone" )
shell.setAlias( "sh", "shell" )
shell.setAlias( "umount", "unmount" )
if term.isColor() then
    shell.setAlias( "background", "bg" )
    shell.setAlias( "foreground", "fg" )
end

-- Setup completion functions
local function completeMultipleChoice( sText, tOptions, bAddSpaces )
    local tResults = {}
    for n=1,#tOptions do
        local sOption = tOptions[n]
        if #sOption + (bAddSpaces and 1 or 0) > #sText and string.sub( sOption, 1, #sText ) == sText then
            local sResult = string.sub( sOption, #sText + 1 )
            if bAddSpaces then
                table.insert( tResults, sResult .. " " )
            else
                table.insert( tResults, sResult )
            end
        end
    end
    return tResults
end
local function completePeripheralName( sText, bAddSpaces )
    return completeMultipleChoice( sText, peripheral.getNames(), bAddSpaces )
end
local tRedstoneSides = redstone.getSides()
local function completeSide( sText, bAddSpaces )
    return completeMultipleChoice( sText, tRedstoneSides, bAddSpaces )
end
local function completeFile( shell, nIndex, sText )
    if nIndex == 1 then
        return fs.complete( sText, shell.dir(), true, false )
    end
end
local function completeDir( shell, nIndex, sText )
    if nIndex == 1 then
        return fs.complete( sText, shell.dir(), false, true )
    end
end
local function completeEither( shell, nIndex, sText )
    if nIndex == 1 then
        return fs.complete( sText, shell.dir(), true, true )
    end
end
local function completeEitherEither( shell, nIndex, sText )
    if nIndex == 1 then
        local tResults = fs.complete( sText, shell.dir(), true, true )
        for n=1,#tResults do
            local sResult = tResults[n]
            if string.sub( sResult, #sResult, #sResult ) ~= "/" then
                tResults[n] = sResult .. " "
            end
        end
        return tResults
    elseif nIndex == 2 then
        return fs.complete( sText, shell.dir(), true, true )
    end
end
local function completeProgram( shell, nIndex, sText )
    if nIndex == 1 then
        return shell.completeProgram( sText )
    end
end
local function completeHelp( _, nIndex, sText )
    if nIndex == 1 then
        return help.completeTopic( sText )
    end
end
local function completeAlias( shell, nIndex, sText )
    if nIndex == 2 then
        return shell.completeProgram( sText )
    end
end
local function completePeripheral( _, nIndex, sText )
    if nIndex == 1 then
        return completePeripheralName( sText )
    end
end
local tGPSOptions = { "host", "host ", "locate" }
local function completeGPS( _, nIndex, sText )
    if nIndex == 1 then
        return completeMultipleChoice( sText, tGPSOptions )
    end
end
local tLabelOptions = { "get", "get ", "set ", "clear", "clear " }
local function completeLabel( _, nIndex, sText )
    if nIndex == 1 then
        return completeMultipleChoice( sText, tLabelOptions )
    elseif nIndex == 2 then
        return completePeripheralName( sText )
    end
end
local function completeMonitor( shell, nIndex, sText )
    if nIndex == 1 then
        return completePeripheralName( sText, true )
    elseif nIndex == 2 then
        local retval = shell.completeProgram( sText )
        if sText == "" then
            table.insert(retval, "resolution ")
        elseif string.find("resolution", sText) == 1 then
            table.insert(retval, string.sub("resolution ", string.len(sText) + 1))
        end
        return retval
    end
end
local tRedstoneOptions = { "probe", "set ", "pulse " }
local function completeRedstone( _, nIndex, sText )
    if nIndex == 1 then
        return completeMultipleChoice( sText, tRedstoneOptions )
    elseif nIndex == 2 then
        return completeSide( sText )
    end
end
local tDJOptions = { "play", "play ", "stop " }
local function completeDJ( _, nIndex, sText )
    if nIndex == 1 then
        return completeMultipleChoice( sText, tDJOptions )
    elseif nIndex == 2 then
        return completePeripheralName( sText )
    end
end
local tPastebinOptions = { "put ", "get ", "run " }
local function completePastebin( shell, nIndex, sText, tPreviousText )
    if nIndex == 1 then
        return completeMultipleChoice( sText, tPastebinOptions )
    elseif nIndex == 2 then
        if tPreviousText[2] == "put" then
            return fs.complete( sText, shell.dir(), true, false )
        end
    end
end
local tChatOptions = { "host ", "join " }
local function completeChat( _, nIndex, sText )
    if nIndex == 1 then
        return completeMultipleChoice( sText, tChatOptions )
    end
end
local function completeSet( _, nIndex, sText )
    if nIndex == 1 then
        return completeMultipleChoice( sText, settings.getNames(), true )
    end
end
local tCommands 
if commands then
    tCommands = commands.list()
end
local function completeExec( _, nIndex, sText )
    if nIndex == 1 and commands then
        return completeMultipleChoice( sText, tCommands, true )
    end
end
local completeAttach, completeDetach, completeConfig, completeUnmount, completeBMPView
if config and mounter and periphemu then -- vanilla?
    local tPeripherals = periphemu.names()
    completeAttach = function(_, nIndex, sText)
        if nIndex == 1 then
            return completeMultipleChoice(sText, {"left", "right", "top", "bottom", "front", "back"}, true)
        elseif nIndex == 2 then
            return completeMultipleChoice(sText, tPeripherals)
        end
    end
    completeDetach = function(_, nIndex, sText)
        if nIndex == 1 then
            return completePeripheralName(sText)
        end
    end
    local tConfig = config.list()
    completeConfig = function(_, nIndex, sText, tPreviousText)
        if nIndex == 1 then
            return completeMultipleChoice(sText, {"list", "set", "get"}, true)
        elseif nIndex == 2 and tPreviousText ~= "list " then
            return completeMultipleChoice(sText, tConfig)
        end
    end
    completeUnmount = function(shell, nIndex, sText)
        if nIndex == 1 then
            return fs.complete(sText, shell.dir(), false, true)
        end
    end
    completeBMPView = function(shell, nIndex, sText)
        if nIndex == 1 then
            return fs.complete(sText, shell.dir(), true, false)
        end
    end
end
shell.setCompletionFunction( "rom/programs/alias.lua", completeAlias )
shell.setCompletionFunction( "rom/programs/cd.lua", completeDir )
shell.setCompletionFunction( "rom/programs/copy.lua", completeEitherEither )
shell.setCompletionFunction( "rom/programs/delete.lua", completeEither )
shell.setCompletionFunction( "rom/programs/drive.lua", completeDir )
shell.setCompletionFunction( "rom/programs/edit.lua", completeFile )
shell.setCompletionFunction( "rom/programs/eject.lua", completePeripheral )
shell.setCompletionFunction( "rom/programs/gps.lua", completeGPS )
shell.setCompletionFunction( "rom/programs/help.lua", completeHelp )
shell.setCompletionFunction( "rom/programs/id.lua", completePeripheral )
shell.setCompletionFunction( "rom/programs/label.lua", completeLabel )
shell.setCompletionFunction( "rom/programs/list.lua", completeDir )
shell.setCompletionFunction( "rom/programs/mkdir.lua", completeFile )
shell.setCompletionFunction( "rom/programs/monitor.lua", completeMonitor )
shell.setCompletionFunction( "rom/programs/move.lua", completeEitherEither )
shell.setCompletionFunction( "rom/programs/redstone.lua", completeRedstone )
shell.setCompletionFunction( "rom/programs/rename.lua", completeEitherEither )
shell.setCompletionFunction( "rom/programs/shell.lua", completeProgram )
shell.setCompletionFunction( "rom/programs/type.lua", completeEither )
shell.setCompletionFunction( "rom/programs/set.lua", completeSet )
shell.setCompletionFunction( "rom/programs/advanced/bg.lua", completeProgram )
shell.setCompletionFunction( "rom/programs/advanced/fg.lua", completeProgram )
shell.setCompletionFunction( "rom/programs/fun/dj.lua", completeDJ )
shell.setCompletionFunction( "rom/programs/fun/advanced/paint.lua", completeFile )
shell.setCompletionFunction( "rom/programs/http/pastebin.lua", completePastebin )
shell.setCompletionFunction( "rom/programs/rednet/chat.lua", completeChat )
shell.setCompletionFunction( "rom/programs/command/exec.lua", completeExec )
if completeAttach then
    shell.setCompletionFunction( "rom/programs/attach.lua", completeAttach )
    shell.setCompletionFunction( "rom/programs/detach.lua", completeDetach )
    shell.setCompletionFunction( "rom/programs/config.lua", completeConfig )
    shell.setCompletionFunction( "rom/programs/unmount.lua", completeUnmount )
    shell.setCompletionFunction( "rom/programs/fun/advanced/bmpview.lua", completeBMPView )
end

if turtle then
    local tGoOptions = { "left", "right", "forward", "back", "down", "up" }
    local function completeGo( _, _, sText )
        return completeMultipleChoice( sText, tGoOptions, true)
    end
    local tTurnOptions = { "left", "right" }
    local function completeTurn( _, _, sText )
            return completeMultipleChoice( sText, tTurnOptions, true )
    end
    local tEquipOptions = { "left", "right" }
    local function completeEquip( _, nIndex, sText )
        if nIndex == 2 then
            return completeMultipleChoice( sText, tEquipOptions )
        end
    end
    local function completeUnequip( _, nIndex, sText )
        if nIndex == 1 then
            return completeMultipleChoice( sText, tEquipOptions )
        end
    end
    shell.setCompletionFunction( "rom/programs/turtle/go.lua", completeGo )
    shell.setCompletionFunction( "rom/programs/turtle/turn.lua", completeTurn )
    shell.setCompletionFunction( "rom/programs/turtle/equip.lua", completeEquip )
    shell.setCompletionFunction( "rom/programs/turtle/unequip.lua", completeUnequip )
end


-- Run autorun files
if fs.exists( "/rom/autorun" ) and fs.isDir( "/rom/autorun" ) then
    local tFiles = fs.list( "/rom/autorun" )
    table.sort( tFiles )
    for _, sFile in ipairs( tFiles ) do
        if string.sub( sFile, 1, 1 ) ~= "." then
            local sNPath = "/rom/autorun/"..sFile
            if not fs.isDir( sNPath ) then
                shell.run( sNPath )
            end
        end
    end
end

local function findStartups( sBaseDir )
    local tStartups
    local sBasePath = "/" .. fs.combine( sBaseDir, "startup" )
    local sStartupNode = shell.resolveProgram( sBasePath )
    if sStartupNode then
        tStartups = { sStartupNode }
    end
    -- It's possible that there is a startup directory and a startup.lua file, so this has to be
    -- executed even if a file has already been found.
    if fs.isDir( sBasePath ) then
        if tStartups == nil then
            tStartups = {}
        end
        for _,v in pairs( fs.list( sBasePath ) ) do
            local sNPath = "/" .. fs.combine( sBasePath, v )
            if not fs.isDir( sNPath ) then
                tStartups[ #tStartups + 1 ] = sNPath
            end
        end
    end
    return tStartups
end

-- Run the user created startup, either from disk drives or the root
local tUserStartups
if settings.get( "shell.allow_startup" ) then
    tUserStartups = findStartups( "/" )
end
if settings.get( "shell.allow_disk_startup" ) then
    for _,sName in pairs( peripheral.getNames() ) do
        if disk.isPresent( sName ) and disk.hasData( sName ) then
            local startups = findStartups( disk.getMountPath( sName ) )
            if startups then
                tUserStartups = startups
                break
            end
        end
    end
end
if tUserStartups then
    for _,v in pairs( tUserStartups ) do
        shell.run( v )
    end
end
--shell.run("rom/programs/list")
