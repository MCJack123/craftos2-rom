multishell.setTitle(multishell.getCurrent(), "Call Stack")
local s, e = pcall(function()
local highlightColour, keywordColour, commentColour, textColour, bgColour, stringColour
local stackWindow, viewerWindow
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
            viewerWindow.setTextColour( colour )
        else
            viewerWindow.setTextColour( colour(match) )
        end
        viewerWindow.write( match )
        viewerWindow.setTextColour( textColour )
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

local w, h = term.getSize()
local selectedLine

local function getCallStack()
    local i = 0
    local retval = {}
    while true do
        local t = debugger.getInfo(i)
        if not t then return retval end
        retval[i+1] = t
        i=i+1
    end
end

local function drawTraceback()
    if viewerWindow then
        viewerWindow.clear()
        viewerWindow.setVisible(false)
        viewerWindow = nil
    end
    local stack = getCallStack()
    stackWindow = window.create(term.current(), 1, 1, w, math.max(#stack + 1, h))
    stackWindow.clear()
    stackWindow.setCursorPos(1, 1)
    stackWindow.setBackgroundColor(colors.black)
    stackWindow.setTextColor(colors.white)
    local numWidth, lineWidth = math.floor(math.log10(#stack)) + 3, 1
    for k,v in ipairs(stack) do lineWidth = math.max(math.floor(math.log10(v.currentline or 0)) + 1, lineWidth) end
    local sourceWidth, nameWidth = math.ceil((w - (numWidth + lineWidth)) / 2), math.floor((w - (numWidth + lineWidth)) / 2)
    stackWindow.write("#")
    stackWindow.setCursorPos(numWidth, 1)
    stackWindow.write("Source")
    stackWindow.setCursorPos(numWidth + sourceWidth, 1)
    stackWindow.write("Name")
    stackWindow.setCursorPos(numWidth + sourceWidth + nameWidth, 1)
    stackWindow.write("@")
    for i,v in ipairs(stack) do
        stackWindow.setCursorPos(1, i + 1)
        stackWindow.setBackgroundColor(selectedLine == i and colors.blue or (i % 2 == 1 and colors.gray or colors.black))
        stackWindow.setTextColor((v.short_src == "[C]" or v.short_src == "(tail call)") and colors.lightGray or colors.white)
        stackWindow.clearLine()
        stackWindow.write(tostring(i))
        stackWindow.setCursorPos(numWidth, i + 1)
        stackWindow.write(string.sub(v.short_src or "?", 1, sourceWidth - 1))
        stackWindow.setCursorPos(numWidth + sourceWidth, i + 1)
        stackWindow.write(string.sub(v.name or "?", 1, nameWidth - 1))
        stackWindow.setCursorPos(numWidth + sourceWidth + nameWidth, i + 1)
        stackWindow.write(tostring(v.currentline or ""))
    end
    if #stack < h - 1 then for i = #stack + 1, h - 1 do 
        stackWindow.setCursorPos(1, i + 1)
        stackWindow.setBackgroundColor(i % 2 == 1 and colors.gray or colors.black)
        stackWindow.clearLine()
    end end
end

local function showFile(info)
    if stackWindow then
        stackWindow.clear()
        stackWindow.setVisible(false)
        stackWindow = nil
    end
    viewerWindow = window.create(term.current(), 1, 1, w, h)
    viewerWindow.clear()
    viewerWindow.setCursorPos(1, 1)
    viewerWindow.setTextColor(colors.blue)
    viewerWindow.setBackgroundColor(colors.white)
    viewerWindow.clearLine()
    viewerWindow.write(" " .. string.char(17) .. " File: " .. string.sub(info.source, 2))
    viewerWindow.setCursorPos(1, 2)
    viewerWindow.setTextColor(colors.white)
    viewerWindow.setBackgroundColor(colors.black)
    if fs.getName(info.source) == "bios.lua" then info.source = "@/debug/bios_reference.lua" end
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
                for i = start, start + h - 2 do 
                    if i == info.currentline then viewerWindow.setBackgroundColor(colors.blue) 
                    else viewerWindow.setBackgroundColor(colors.black) end
                    viewerWindow.clearLine()
                    if lines[i] ~= nil then writeHighlighted(lines[i]) end
                    if i ~= start + h then viewerWindow.setCursorPos(1, select(2, viewerWindow.getCursorPos()) + 1) end
                end
            else 
                viewerWindow.setTextColor(colors.red)
                viewerWindow.write("Could not open source") 
            end
        else 
            viewerWindow.setTextColor(colors.red)
            viewerWindow.write("Could not find source") 
        end
    else 
        viewerWindow.write("No source available")
    end
end

print("Waiting for break...")
local wait = true
while true do
    if wait then os.pullEvent("debugger_break") end
    w, h = term.getSize()
    drawTraceback()
    local screen = false
    wait = true
    while true do
        local ev, p1, p2, p3 = os.pullEvent()
        if ev == "key" and p1 == keys.enter then 
            debugger.step()
            debugger.waitForBreak()
            wait = false
            break
        elseif ev == "mouse_click" and p1 == 1 then 
            if screen then
                if p2 >= 1 and p2 <= 3 and p3 == 1 then
                    selectedLine = nil
                    screen = false
                    drawTraceback()
                end
            else
                if selectedLine == p3 - 1 then
                    local info = debugger.getInfo(p3 - 2)
                    if info.short_src ~= "[C]" and info.short_src ~= "(tail call)" then
                        screen = true
                        showFile(info)
                    end
                else
                    selectedLine = p3 - 1
                    drawTraceback()
                end
            end
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