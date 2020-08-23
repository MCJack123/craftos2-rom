if _CCPC_FIRST_RUN then
    print([[Welcome to CraftOS-PC! This is the ComputerCraft shell prompt, where you can run programs.
* Type "programs" to see the programs you can run.
* Type "help <program>" to see help for a specific program.
* Read the documentation at https://www.craftos-pc.cc/docs/.
* Report bugs to https://www.craftos-pc.cc/bugreport.
]])
elseif _CCPC_UPDATED_VERSION then
    print("CraftOS-PC has been updated to " .. _HOST:match("CraftOS%-PC [%a]* ?(v[%d%.]+)") .. ". To see the new changes, type \"help whatsnew\".")
else
    local tMotd = {}

    for sPath in string.gmatch(settings.get( "motd.path" ), "[^:]+") do
        if fs.exists(sPath) then
            for sLine in io.lines(sPath) do
                table.insert(tMotd,sLine)
            end
        end
    end

    if #tMotd == 0 then
        print("missingno")
    else
        print(tMotd[math.random(1,#tMotd)])
    end
end
