local args = { ... }

if args[2] ~= nil then
    local ro = nil
    if args[3] == "readOnly" or args[3] == "true" then ro = true
    elseif args[3] == "false" then ro = false end
    mounter.mount(args[1], args[2], ro)
elseif args[1] == "--help" then
    term.setTextColor(colors.red)
    print("Usage: mount <name> <path> [readOnly]")
    print("       mount --help")
    print("       mount")
    term.setTextColor(colors.white)
else
    local mounts = mounter.list()
    print("/ on computer/0")
    for k,v in pairs(mounts) do
        write("/" .. k .. " on " .. v)
        if mounter.isReadOnly(k) then print(" (read-only)") else print() end
    end
end