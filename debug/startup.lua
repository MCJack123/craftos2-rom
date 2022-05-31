if debugger.useDAP and debugger.useDAP() then
    shell.run("debug/adapter.lua")
else
    shell.openTab("debug/showfile.lua")
    shell.openTab("debug/profiler.lua")
    shell.openTab("debug/console.lua")
    shell.run("debug/debugger.lua")
end
shell.exit()