multishell.setTitle(multishell.getCurrent(), "File Viewer")
local s, e = pcall(function()
local highlightColour, keywordColour, commentColour, textColour, bgColour, stringColour
if term.isColour() then
    bgColour = colours.black
    textColour = colours.white
    highlightColour = colours.yellow
    keywordColour = colours.yellow
    commentColour = colours.green
    stringColour = colours.red
else
    bgColour = colours.black
    textColour = colours.white
    highlightColour = colours.white
    keywordColour = colours.white
    commentColour = colours.white
    stringColour = colours.white
end
local tKeywords = {
    ["and"] = true,
    ["break"] = true,
    ["do"] = true,
    ["else"] = true,
    ["elseif"] = true,
    ["end"] = true,
    ["false"] = true,
    ["for"] = true,
    ["function"] = true,
    ["if"] = true,
    ["in"] = true,
    ["local"] = true,
    ["nil"] = true,
    ["not"] = true,
    ["or"] = true,
    ["repeat"] = true,
    ["return"] = true,
    ["then"] = true,
    ["true"] = true,
    ["until"]= true,
    ["while"] = true,
}

local function tryWrite( sLine, regex, colour )
    local match = string.match( sLine, regex )
    if match then
        if type(colour) == "number" then
            term.setTextColour( colour )
        else
            term.setTextColour( colour(match) )
        end
        term.write( match )
        term.setTextColour( textColour )
        return string.sub( sLine, string.len(match) + 1 )
    end
    return nil
end

local function writeHighlighted( sLine )
    while string.len(sLine) > 0 do    
        sLine = 
            tryWrite( sLine, "^%-%-%[%[.-%]%]", commentColour ) or
            tryWrite( sLine, "^%-%-.*", commentColour ) or
            tryWrite( sLine, "^\"\"", stringColour ) or
            tryWrite( sLine, "^\".-[^\\]\"", stringColour ) or
            tryWrite( sLine, "^\'\'", stringColour ) or
            tryWrite( sLine, "^\'.-[^\\]\'", stringColour ) or
            tryWrite( sLine, "^%[%[.-%]%]", stringColour ) or
            tryWrite( sLine, "^[%w_]+", function( match )
                if tKeywords[ match ] then
                    return keywordColour
                end
                return textColour
            end ) or
            tryWrite( sLine, "^[^%w_]", textColour )
    end
end

print("Waiting for break...")
local wait = true
while true do
    if wait then os.pullEvent("debugger_break") end
    local info = debugger.getInfo()
    local w, h = term.getSize()
    h=h-1
    if info.source and info.currentline then
        if fs.exists(string.sub(info.source, 2)) then
            local file = fs.open(string.sub(info.source, 2), "r")
            if file ~= nil then
                local lines = {}
                local l = file.readLine()
                while l ~= nil do 
                    l = string.gsub(l, "\t", "    ")
                    table.insert(lines, l)
                    l = file.readLine()
                end
                file.close()
                local start
                if info.currentline < h / 2 then start = 1
                elseif info.currentline > #lines - (h / 2) then start = #lines - h
                else start = info.currentline - math.floor(h / 2) end
                term.clear()
                term.setCursorPos(1, 1)
                term.setTextColor(colors.blue)
                term.setBackgroundColor(colors.white)
                term.clearLine()
                print(" File: " .. string.sub(info.source, 2))
                term.setTextColor(colors.white)
                term.setBackgroundColor(colors.black)
                for i = start, start + h - 2 do 
                    if i == info.currentline then term.setBackgroundColor(colors.blue) 
                    else term.setBackgroundColor(colors.black) end
                    term.clearLine()
                    if lines[i] ~= nil then writeHighlighted(lines[i]) end
                    if i ~= start + h then print() end
                end
            else 
                term.clear()
                term.setCursorPos(1, 1)
                printError("Could not open source at " .. string.sub(info.source, 2)) 
            end
        else 
            term.clear()
            term.setCursorPos(1, 1)
            printError("Could not find source at " .. string.sub(info.source, 2)) 
        end
    else 
        term.clear()
        term.setCursorPos(1, 1)
        print("No source available") 
    end
    wait = true
    while true do
        local ev, p1 = os.pullEvent()
        if ev == "key" and p1 == keys.enter then 
            debugger.step()
            debugger.waitForBreak()
            wait = false
            break
        elseif ev == "debugger_done" then break end
    end
    if wait then
        term.clear()
        term.setCursorPos(1, 1)
        print("Waiting for break...")
    end
end
end)
if not s then printError(e) end
while true do os.pullEvent() end