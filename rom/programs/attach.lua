local args = { ... }
if type(args[1]) ~= "string" or type(args[2]) ~= "string" then
    print("Usage: attach <side> <type> [options...]")
else 
    if peripheral.isPresent(args[1]) and peripheral.getType(args[1]) == args[2] then 
        print("Peripheral already attached")
        return
    end
    if tonumber(args[3]) ~= nil then args[3] = tonumber(args[3]) end
    if not periphemu.create(args[1], args[2], args[3]) then printError("Could not attach peripheral") end
end