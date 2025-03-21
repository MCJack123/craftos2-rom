-- SPDX-FileCopyrightText: 2023 The CC: Tweaked Developers
--
-- SPDX-License-Identifier: MPL-2.0

-- Internal module for handling file uploads. This has NO stability guarantees,
-- and so SHOULD NOT be relyed on in user code.

local completion = require "cc.completion"

return function(files)
    local closed = {}
    local function closeAll()
        for _, file in pairs(files) do
            if not closed[file] then
                closed[file] = true
                file.close()
            end
        end
    end
    
    local overwrite = {}
    for _, file in pairs(files) do
        local filename = file.getName()
        local path = shell.resolve(filename)
        if fs.exists(path) then
            if fs.isDir(path) then
                closeAll()
                return nil, filename .. " is already a directory."
            end

            overwrite[#overwrite + 1] = filename
        end
    end

    if #overwrite > 0 then
        table.sort(overwrite)
        printError("The following files will be overwritten:")
        textutils.pagedTabulate(colours.cyan, overwrite)

        while true do
            io.write("Overwrite? (yes/no) ")
            local input = read(nil, nil, function(t)
                return completion.choice(t, { "yes", "no" })
            end)
            if not input then closeAll() return end

            input = input:lower()
            if input == "" or input == "yes" or input == "y" then
                break
            elseif input == "no" or input == "n" then
                closeAll()
                return
            end
        end
    end

    for _, file in pairs(files) do
        local filename = file.getName()
        print("Transferring " .. filename)

        local path = shell.resolve(filename)
        local handle, err = fs.open(path, "wb")
        if not handle then closeAll() return nil, err end

        -- Write the file without loading it all into memory. This uses the same buffer size
        -- as BinaryReadHandle. It would be really nice to have a way to do this without
        -- multiple copies.
        while true do
            local chunk = file.read(8192)
            if not chunk then break end

            local ok, err = pcall(handle.write, chunk)
            if not ok then
                handle.close()

                -- Probably an out-of-space issue, just bail.
                if err:sub(1, 7) == "pcall: " then err = err:sub(8) end
                closeAll()
                return nil, "Failed to write file (" .. err .. "). File may be corrupted"
            end
        end

        handle.close()
        file.close()
        closed[file] = true
    end

    return true
end
