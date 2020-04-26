-- gist.lua - Gist client for ComputerCraft
-- Made by JackMacWindows for CraftOS-PC and CC: Tweaked

-- Actual program

local function getGistFile(data)
    if not data.truncated then return data.content else
        local handle = http.get(data.raw_url)
        if not handle then error("Could not connect to api.github.com.") end
        if handle.getResponseCode() ~= 200 then
            handle.close()
            error("Failed to download file data.")
        end
        local d = handle.readAll()
        handle.close()
        return d
    end
end

-- ID can be either just the gist ID or a gist ID followed by a slash and a file name
-- * If a file name is specified, retrieves that file
-- * Otherwise, if there's only one file, retrieves that file
-- * Otherwise, if there's a file named 'init.lua', retrieves 'init.lua'
-- * Otherwise, if there's more than one file but only one *.lua file, retrieves the Lua file
-- * Otherwise, retrieves the first Lua file alphabetically (with a warning)
-- * Otherwise, fails
local function getGistData(id)
    local file
    if id:find("/") ~= nil then id, file = id:match("^([0-9A-Fa-f:]+)/(.+)$") end
    if id:find(":") ~= nil then id = id:gsub(":", "/") end
    write("Connecting to api.github.com... ")
    local handle = http.get("https://api.github.com/gists/" .. id)
    if handle == nil then print("Failed.") return nil end
    if handle.getResponseCode() ~= 200 then print("Failed.") handle.close() return nil end
    local meta = textutils.unserializeJSON(handle.readAll())
    handle.close()
    if meta == nil or meta.files == nil then print("Failed.") return nil end
    print("Success.")
    if file then return getGistFile(meta.files[file]), file
    elseif next(meta.files, next(meta.files)) == nil then return getGistFile(meta.files[next(meta.files)]), next(meta.files)
    elseif meta.files["init.lua"] ~= nil then return getGistFile(meta.files["init.lua"]), "init.lua"
    else
        local luaFiles = {}
        for k in pairs(meta.files) do if k:match("%.lua$") then table.insert(luaFiles, k) end end
        table.sort(luaFiles)
        if #luaFiles == 0 then
            print("Error: Could not find any Lua files to download!")
            return nil
        end
        if #luaFiles > 1 then print("Warning: More than one Lua file detected, downloading the first one alphabetically.") end
        return getGistFile(meta.files[luaFiles[1]]), luaFiles[1]
    end
end

local function setTextColor(c) if term.isColor() then term.setTextColor(c) elseif c == colors.white then term.setTextColor(c) else term.setTextColor(colors.lightGray) end end

local function requestAuth(headers)
    if settings.get("gist.id") ~= nil then headers.Authorization = "token " .. settings.get("gist.id") else
        setTextColor(colors.yellow)
        write("You need to add a Personal Access Token (PAK) to upload Gists. Follow the instructions at ")
        setTextColor(colors.blue)
        write("https://tinyurl.com/GitHubPAK")
        setTextColor(colors.yellow)
        write(" to generate one. Make sure to check the '")
        setTextColor(colors.blue)
        write("gist")
        setTextColor(colors.yellow)
        print("' checkbox on step 7 (under 'Select scopes'). Once done, paste it here.")
        setTextColor(colors.lime)
        write("PAK: ")
        setTextColor(colors.white)
        local pak = read()
        if pak == nil or pak == "" then error("Invalid PAK, please try again.") end
        settings.set("gist.id", pak)
        headers.Authorization = "token " .. pak
    end
end

local args = {...}

local helpstr = "Usages:\ngist put <filenames...> [-- description...]\ngist edit <id> <filenames...> [-- description]\ngist delete <id>\ngist get <id> <filename>\ngist run <id> [arguments...]\ngist info <id>"

if #args < 2 then
    print(helpstr)
    return 1
end

if not http then
    printError("Gist requires http API")
    if _G.config ~= nil then printError("Set http_enable to true in the CraftOS-PC configuration")
    else printError("Set http_enable to true in ComputerCraft's configuration'") end
    return 2
end

if args[1] == "get" then
    if #args < 3 then print(helpstr) return 1 end
    local data = getGistData(args[2])
    if data == nil then return 3 end
    local file = fs.open(shell.resolve(args[3]), "w")
    file.write(data)
    file.close()
    print("Downloaded as " .. shell.resolve(args[3]))
elseif args[1] == "run" then
    local data, name = getGistData(args[2])
    if data == nil then return 3 end
    local fn, err = load(data, name, "t", _ENV)
    if fn == nil then error(err) end
    local ok, msg = pcall(fn, table.unpack(args, 3))
    if not ok then error(msg) end
elseif args[1] == "put" then
    local data = {files = {}, public = true}
    local i = 2
    while args[i] ~= nil and args[i] ~= "--" do
        if data.files[fs.getName(args[i])] then print("Cannot upload files with duplicate names.") return 2 end
        local file = fs.open(shell.resolve(args[i]), "r")
        if file == nil then print("Could not read " .. shell.resolve(args[i]) .. ".") return 2 end
        data.files[fs.getName(args[i])] = {content = file.readAll()}
        file.close()
        i = i + 1
    end
    if args[i] == "--" then data.description = table.concat({table.unpack(args, i + 1)}, " ") end
    local jsonfiles = ""
    for k, v in pairs(data.files) do jsonfiles = jsonfiles .. (jsonfiles == "" and "" or ",\n") .. ("    \"%s\": {\n      \"content\": %s\n    }"):format(k, textutils.serializeJSON(v.content)) end
    if jsonfiles == "" then print("No such file") return 2 end
    local jsondata = ([[{
  "description": %s,
  "public": true,
  "files": {
%s
  }
}]]):format(data.description and '"' .. data.description .. '"' or "null", jsonfiles)
    local headers = {["Content-Type"] = "application/json"}
    requestAuth(headers)
    write("Connecting to api.github.com... ")
    local handle = http.post("https://api.github.com/gists", jsondata, headers)
    if handle == nil then print("Failed.") return 3 end
    local resp = textutils.unserializeJSON(handle.readAll())
    if handle.getResponseCode() ~= 201 or resp == nil then print("Failed: " .. handle.getResponseCode() .. ": " .. (resp and textutils.serializeJSON(resp) or "Unknown error")) handle.close() return 3 end
    handle.close()
    print("Success.\nUploaded as " .. resp.html_url .. "\nRun 'gist get " .. resp.id .. "' to download anywhere")
elseif args[1] == "info" then
    local id = args[2]
    if id:find("/") ~= nil then id = id:match("^([0-9A-Fa-f:]+)/.+$") end
    if id:find(":") ~= nil then id = id:gsub(":", "/") end
    write("Connecting to api.github.com... ")
    local handle = http.get("https://api.github.com/gists/" .. id)
    if handle == nil then print("Failed.") return 3 end
    if handle.getResponseCode() ~= 200 then print("Failed.") handle.close() return 3 end
    local meta = textutils.unserializeJSON(handle.readAll())
    handle.close()
    if meta == nil or meta.files == nil then print("Failed.") return 3 end
    local f = {}
    for k in pairs(meta.files) do table.insert(f, k) end
    table.sort(f)
    print("Success.")
    setTextColor(colors.yellow)
    write("Description: ")
    setTextColor(colors.white)
    print(meta.description)
    setTextColor(colors.yellow)
    write("Author: ")
    setTextColor(colors.white)
    print(meta.owner.login)
    setTextColor(colors.yellow)
    write("Revisions: ")
    setTextColor(colors.white)
    print(#meta.history)
    setTextColor(colors.yellow)
    print("Files in this Gist:")
    setTextColor(colors.white)
    textutils.tabulate(f)
elseif args[1] == "edit" then
    if #args < 3 then print(helpstr) return 1 end
    local data = {files = {}, public = true}
    local id = args[2]
    if id:find("/") ~= nil then id = id:match("^([0-9A-Fa-f:]+)/.+$") end
    if id:find(":") ~= nil then id = id:gsub(":", "/") end
    local i = 3
    while args[i] ~= nil and args[i] ~= "--" do
        if data.files[fs.getName(args[i])] then error("Cannot upload files with duplicate names.") end
        local file = fs.open(shell.resolve(args[i]), "r")
        if file == nil then data.files[fs.getName(args[i])] = {} else
            data.files[fs.getName(args[i])] = {content = file.readAll()}
            file.close()
        end
        i = i + 1
    end
    if args[i] == "--" then data.description = table.concat({table.unpack(args, i + 1)}, " ") else
        write("Connecting to api.github.com... ")
        local handle = http.get("https://api.github.com/gists/" .. id)
        if handle == nil then print("Failed.") return 3 end
        if handle.getResponseCode() ~= 200 then print("Failed.") handle.close() return 3 end
        local meta = textutils.unserializeJSON(handle.readAll())
        handle.close()
        if meta == nil or meta.files == nil then print("Failed.") return 3 end
        data.description = meta.description
        print("Success.")
    end
    -- Get authorization
    local headers = {["Content-Type"] = "application/json"}
    requestAuth(headers)
    local jsonfiles = ""
    for k, v in pairs(data.files) do jsonfiles = jsonfiles .. (jsonfiles == "" and "" or ",\n") .. (v.content == nil and ("    \"%s\": null"):format(k) or ("    \"%s\": {\n      \"content\": %s\n    }"):format(k, textutils.serializeJSON(v.content))) end
    local jsondata = ([[{
  "description": %s,
  "public": true,
  "files": {
%s
  }
}]]):format(data.description and '"' .. data.description .. '"' or "null", jsonfiles)
    write("Connecting to api.github.com... ")
    local handle
    if http.patch ~= nil then handle = http.patch("https://api.github.com/gists/" .. id, jsondata, headers)
    elseif http.websocket ~= nil then handle = http.post{url = "https://api.github.com/gists/" .. id, body = jsondata, headers = headers, method = "PATCH"}
    else print("Failed: This version of ComputerCraft doesn't support the PATCH method. Update to CC: Tweaked or a compatible emulator (CraftOS-PC, CCEmuX) to use 'edit'.") return 3 end
    if handle == nil then print("Failed.") return 3 end
    local resp = textutils.unserializeJSON(handle.readAll())
    if handle.getResponseCode() ~= 200 or resp == nil then print("Failed: " .. handle.getResponseCode() .. ": " .. (resp and textutils.serializeJSON(resp) or "Unknown error")) handle.close() return 3 end
    handle.close()
    print("Success.\nUploaded as " .. resp.html_url .. "\nRun 'gist get " .. resp.id .. "' to download anywhere")
elseif args[1] == "delete" then
    local id = args[2]
    if id:find("/") ~= nil or id:find(":") ~= nil then id = id:match("^([0-9A-Fa-f]+)") end
    local headers = {}
    requestAuth(headers)
    local handle
    write("Connecting to api.github.com... ")
    if http.delete ~= nil then handle = http.delete("https://api.github.com/gists/" .. id, nil, headers)
    elseif http.websocket ~= nil then handle = http.post{url = "https://api.github.com/gists/" .. id, headers = headers, method = "DELETE"}
    else print("Failed: This version of ComputerCraft doesn't support the DELETE method. Update to CC: Tweaked or a compatible emulator (CraftOS-PC, CCEmuX) to use 'edit'.") return 3 end
    if handle == nil then print("Failed.") return 3 end
    if handle.getResponseCode() ~= 204 then print("Failed: " .. handle.getResponseCode() .. ".") handle.close() return 3 end
    handle.close()
    print("Success.")
    print("The requested Gist has been deleted.")
else print(helpstr) return 1 end
