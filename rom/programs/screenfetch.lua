local ccart = [[------------------------
|                      |
| -------------------- |
| | \                | |
| | / __             | |
| |                  | |
| |                  | |
| |                  | |
| |                  | |
| |                  | |
| |                  | |
| -------------------- |
|                      |
|                  [=] |
|                      |
------------------------]]

local ccart_fg = [[ffffffffffffffffffffffff
f7777777777777777777777f
f7ffffffffffffffffffff7f
f7ff0fffffffffffffffff7f
f7ff0f00ffffffffffffff7f
f7ffffffffffffffffffff7f
f7ffffffffffffffffffff7f
f7ffffffffffffffffffff7f
f8ffffffffffffffffffff8f
f8ffffffffffffffffffff8f
f8ffffffffffffffffffff8f
f8ffffffffffffffffffff8f
f8888888888888888888888f
f888888888888888888fff8f
f8888888888888888888888f
ffffffffffffffffffffffff]]

local ccart_bg = [[ffffffffffffffffffffffff
f7777777777777777777777f
f7ffffffffffffffffffff7f
f7ffffffffffffffffffff7f
f7ffffffffffffffffffff7f
f7ffffffffffffffffffff7f
f7ffffffffffffffffffff7f
f7ffffffffffffffffffff7f
f8ffffffffffffffffffff8f
f8ffffffffffffffffffff8f
f8ffffffffffffffffffff8f
f8ffffffffffffffffffff8f
f8888888888888888888888f
f888888888888888888fff8f
f8888888888888888888888f
ffffffffffffffffffffffff]]

local ccart_adv_fg = [[ffffffffffffffffffffffff
f4444444444444444444444f
f4ffffffffffffffffffff4f
f4ff0fffffffffffffffff4f
f4ff0f00ffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4444444444444444444444f
f444444444444444444ddd4f
f4444444444444444444444f
ffffffffffffffffffffffff]]

local ccart_adv_bg = [[ffffffffffffffffffffffff
f4444444444444444444444f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4ffffffffffffffffffff4f
f4444444444444444444444f
f444444444444444444ddd4f
f4444444444444444444444f
ffffffffffffffffffffffff]]

local function fg(l) if term.isColor() then return string.rep("4", l) else return string.rep("8", l) end end
local function text(title, str) return {title .. str, fg(string.len(title)) .. string.rep("0", string.len(str)), string.rep("f", string.len(title .. str))} end

local function time(n)
    local h = math.floor(n / 3600)
    local m = math.floor(n / 60) % 60
    local s = n % 60
    local retval = s .. "s"
    if m > 0 or h > 0 then retval = m .. "m " .. retval end
    if h > 0 then retval = h .. "h " .. retval end
    return retval
end

local function ext(retval)
    if http ~= nil then table.insert(retval, text("    ", "HTTP enabled")) 
    if http.websocket ~= nil then table.insert(retval, text("    ", "CC: Tweaked")) end end
    if mounter ~= nil then table.insert(retval, text("    ", "CraftOS-PC")) end
    if term.setGraphicsMode ~= nil then table.insert(retval, text("    ", "CraftOS-PC GFX")) end
    if term.screenshot ~= nil then table.insert(retval, text("    ", "CraftOS-PC 2")) end
    if ccemux ~= nil then table.insert(retval, text("    ", "CCEmuX")) end
    if fs.exists(".mbs") or fs.exists("rom/.mbs") then table.insert(retval, text("    ", "MBS")) end
    if type(kernel) == "table" then table.insert(retval, text("    ", "CCKernel2")) end
    return retval
end

local sysinfo = {
    text(os.getComputerLabel() or "Untitled Computer", ""),
    text("Type: ", commands ~= nil and "Command Computer" or term.isColor() and "Advanced Computer" or "Standard Computer"),
    text("OS: ", os.version()),
    text("Lua: ", _VERSION),
    text("Host: ", _HOST),
    text("Uptime: ", time(os.clock())),
    text("Extensions: ", "")
}
ext(sysinfo)

print("")
for i = 1, string.len(ccart), 25 do 
    term.blit(string.sub(ccart, i, i+23), string.sub(term.isColor() and ccart_adv_fg or ccart_fg, i, i+23), string.sub(term.isColor() and ccart_adv_bg or ccart_bg, i, i+23))
    write("  ")
    if sysinfo[((i-1)/25)+1] ~= nil then term.blit(table.unpack(sysinfo[((i-1)/25)+1])) end
    print("")
end
print("")
if term.screenshot ~= nil then term.screenshot() end
sleep(0.25)