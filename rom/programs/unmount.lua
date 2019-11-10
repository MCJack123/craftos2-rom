local args = { ... }
if args[1] ~= nil then mounter.unmount(args[1])
else print("Usage: unmount <name>") end

