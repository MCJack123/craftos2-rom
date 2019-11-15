multishell.setTitle(multishell.getCurrent(), "Debugger")
local ok, err = pcall(function()
local history = {}
local function split(inputstr, sep)
    sep = sep or "%s"
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do table.insert(t, str) end
    return t
end
term.setTextColor(colors.yellow)
print("CraftOS-PC Debugger")
while true do
    debugger.waitForBreak()
    local info = debugger.getInfo()
    if fs.getName(info.source) == "bios.lua" then info.source = "@/debug/bios_reference.lua" end
    term.setTextColor(colors.blue)
    print("Break at " .. (info.short_src or "?") .. ":" .. (info.currentline or "?") .. " (" .. (info.name or "?") .. "): " .. debugger.getReason())
    if info.source and info.currentline and fs.exists(string.sub(info.source, 2)) then
        local file = fs.open(string.sub(info.source, 2), "r")
        for i = 1, info.currentline - 1 do file.readLine() end
        term.setTextColor(colors.lime)
        write("--> ")
        term.setTextColor(colors.white)
        print(select(1, string.gsub(file.readLine(), "^[ \t]+", "")))
        file.close()
    end
    local loop = true
    while loop do
        term.setTextColor(colors.yellow)
        write("(ccdb) ")
        term.setTextColor(colors.white)
        local cmd = read(nil, history)
        if cmd == "" then cmd = history[#history] 
        else table.insert(history, cmd) end
        local action = split(cmd)
        if action[1] == "step" or action[1] == "s" then debugger.step(); loop = false
        elseif action[1] == "finish" or action[1] == "fin" then debugger.stepOut(); loop = false
        elseif action[1] == "continue" or action[1] == "c" then debugger.continue(); loop = false
        elseif action[1] == "b" then debugger.setBreakpoint(string.sub(action[2], 1, string.find(action[2], ":") - 1), tonumber(string.sub(action[2], string.find(action, ":") + 1)))
        elseif (action[1] == "breakpoint" or action[2] == "break") and action[2] == "set" then debugger.setBreakpoint(string.sub(action[3], 1, string.find(action[3], ":") - 1), tonumber(string.sub(action[3], string.find(action[3], ":") + 1)))
        elseif action[1] == "print" or action[1] == "p" then 
            table.remove(action, 1)
            local s = table.concat(action, " ")
            local tEnv = setmetatable({_echo = function( ... ) return ... end, pairs = pairs, print = print, write = write, term = term, getmetatable = getmetatable}, {__index = debugger.getfenv()})
            local nForcePrint = 0
            local func, e = load( s, "lua", "t", tEnv )
            local func2, e2 = load( "return _echo("..s..");", "lua", "t", tEnv )
            if not func then
                if func2 then
                    func = func2
                    e = nil
                    nForcePrint = 1
                end
            else
                if func2 then
                    func = func2
                end
            end
            if func then
                local tResults = table.pack( debugger.run( func ) )
                if tResults[1] then
                    local n = 1
                    while n < tResults.n or (n <= nForcePrint) do
                        local value = tResults[ n + 1 ]
                        if type( value ) == "table" then
                            local metatable = getmetatable( value )
                            if type(metatable) == "table" and type(metatable.__tostring) == "function" then
                                print( tostring( value ) )
                            else
                                local ok, serialised = pcall( textutils.serialise, value )
                                if ok then
                                    print( serialised )
                                else
                                    print( tostring( value ) )
                                end
                            end
                        else
                            print( tostring( value ) )
                        end
                        n = n + 1
                    end
                else
                    printError( tResults[2] )
                end
            else
                printError( e )
            end
        elseif action[1] == "x" then
            table.remove(action, 1)
            local s = table.concat(action, " ")
            local tEnv = setmetatable({_echo = function( ... ) return ... end}, {__index = _ENV})
            local nForcePrint = 0
            local func, e = load( s, "lua", "t", tEnv )
            local func2, e2 = load( "return _echo("..s..");", "lua", "t", tEnv )
            if not func then
                if func2 then
                    func = func2
                    e = nil
                    nForcePrint = 1
                end
            else
                if func2 then
                    func = func2
                end
            end
            if func then
                local tResults = table.pack( pcall( func ) )
                if tResults[1] then
                    local n = 1
                    while n < tResults.n or (n <= nForcePrint) do
                        local value = tResults[ n + 1 ]
                        if type( value ) == "table" then
                            local metatable = getmetatable( value )
                            if type(metatable) == "table" and type(metatable.__tostring) == "function" then
                                print( tostring( value ) )
                            else
                                local ok, serialised = pcall( textutils.serialise, value )
                                if ok then
                                    print( serialised )
                                else
                                    print( tostring( value ) )
                                end
                            end
                        else
                            print( tostring( value ) )
                        end
                        n = n + 1
                    end
                else
                    printError( tResults[2] )
                end
            else
                printError( e )
            end
        elseif action[1] == "backtrace" or action[1] == "bt" then print(debugger.run(debug.traceback))
        elseif action[1] == "quit" or action[1] == "q" then return -- delete this before release
        end
        lastaction = cmd
    end
    os.queueEvent("debugger_done")
end
end)
if not ok then printError(err) end
while os.pullEvent() do end