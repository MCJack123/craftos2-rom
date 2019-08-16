local args = { ... }
if type(args[1]) ~= "string" or type(args[2]) ~= "string" then
    print("Usage: attach <side> <type> [options...]")
else periphemu.create(args[1], args[2], args[3]) end