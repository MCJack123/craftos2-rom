local args = { ... }

if args[2] ~= nil then
    mounter.mount(args[1], args[2], args[3] ~= "readOnly")
elseif args[1] == "--help" then
    term.setTextColor(colors.red)
    print("Usage: mount <name> <path> [readOnly]")
    print("       mount --help")
    print("       mount")
    term.setTextColor(colors.white)
else
    local mounts = mounter.list()
    print("/ on computer/0")
    print("/rom on assets/computercraft/lua/rom (read-only)")
    for k,v in pairs(mounts) do
        write("/" .. k .. " on " .. v)
        if mounter.isReadOnly(k) then print(" (read-only)") else print() end
    end
end