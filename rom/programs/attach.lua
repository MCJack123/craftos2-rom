local args = { ... }
if type(args[1]) ~= "string" or type(args[2]) ~= "string" then
    print("Usage: attach <side> <type> [options...]")
else 
    if tonumber(args[3]) ~= nil then args[3] = tonumber(args[3]) end
    periphemu.create(args[1], args[2], args[3]) 
end