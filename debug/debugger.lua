multishell.setTitle(multishell.getCurrent(), "Debugger")
local lastaction = "s"
while true do
    debugger.waitForBreak()
    local info = debugger.getInfo()
    term.setTextColor(colors.blue)
    print("Break at " .. (info.short_src or "?") .. ":" .. (info.currentline or "?") .. " (" .. (info.name or "?") .. ")")
    if info.source and info.currentline and fs.exists(string.sub(info.source, 2)) then
        local file = fs.open(string.sub(info.source, 2), "r")
        for i = 1, info.currentline - 1 do file.readLine() end
        term.setTextColor(colors.lime)
        write("--> ")
        term.setTextColor(colors.white)
        print(string.gsub(file.readLine(), "^ +", ""))
        file.close()
    end
    term.setTextColor(colors.yellow)
    write("(ccdb) ")
    term.setTextColor(colors.white)
    local action = read()
    if action == "" then action = lastaction end
    if action == "step" or action == "s" then debugger.step()
    elseif action == "finish" or action == "fin" then debugger.stepOut()
    elseif action == "continue" or action == "c" then debugger.continue()
    elseif string.sub(action, 1, 2) == "b " then debugger.setBreakpoint(string.sub(action, 3, string.find(action, ":") - 1), tonumber(string.sub(action, string.find(action, ":") + 1)))
    elseif action == "quit" or action == "q" then break end
    lastaction = action
end