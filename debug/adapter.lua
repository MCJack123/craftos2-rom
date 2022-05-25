print("The debug adapter is running. Please do not close this window.")
term.setCursorBlink(false)

local ok, err = pcall(function()

local nextSequence = 1

local function sendMessage(message, headers)
    message.seq = nextSequence
    nextSequence = nextSequence + 1
    local data = textutils.serializeJSON(message)
    local packet = "Content-Length: " .. #data .. "\r\n"
    if headers then for k, v in pairs(headers) do packet = packet .. k .. ": " .. v .. "\r\n" end end
    packet = packet .. "\r\n" .. data
    print(packet)
    debugger.sendDAPData(packet)
end

local responseWait = {}
local initConfig = {}
local pause = false
local launchCommand

local reasonMap = {
    ["debug.debug() called"] = "breakpoint",
    ["Pause"] = "pause",
    ["Breakpoint"] = "breakpoint",
    ["Error"] = "exception",
    ["Resume"] = "exception",
    ["Yield"] = "exception",
    ["Caught call"] = "exception",
}

local commands, events = {}, {}

function commands.initialize(args)
    initConfig = args
    return {
        supportsConfigurationDoneRequest = true,
        supportsFunctionBreakpoints = true,
        supportsConditionalBreakpoints = true,
        supportsHitConditionalBreakpoints = true,
        supportsEvaluateForHovers = true,
        exceptionBreakpointFilters = {
            {
                filter = "error",
                label = "Error",
                description = "Breaks on any thrown error"
            },
            {
                filter = "load",
                label = "Load code",
                description = "Breaks when calling loadfile, loadAPI, require"
            },
            {
                filter = "run",
                label = "Run program",
                description = "Breaks when calling os.run, shell.run, dofile"
            },
            {
                filter = "resume",
                label = "Resume coroutine",
                description = "Breaks when resuming any coroutine"
            },
            {
                filter = "yield",
                label = "Yield coroutine",
                description = "Breaks when any coroutine yields"
            }
        },
        supportsStepBack = false,
        supportsSetVariable = true,
        supportsGotoTargetsRequest = false,
        supportsStepInTargetsRequest = false,
        supportsCompletionsRequest = false,
        supportsModulesRequest = false,
        --supportedChecksumAlgorithms = {"timestamp"},
        supportsRestartRequest = true,
        supportsExceptionOptions = false,
        supportsValueFormattingOptions = true,
        supportsExceptionInfoRequest = true,
        supportTerminateDebuggee = true,
        supportSuspendDebuggee = true,
        supportsDelayedStackTraceLoading = true,
        supportsLoadedSourcesRequest = true,
        supportsLogPoints = true,
        supportsTerminateThreadsRequest = false,
        supportsSetExpression = true,
        supportsTerminateRequest = true,
        supportsDataBreakpoints = false,
        supportsReadMemoryRequest = false,
        supportsWriteMemoryRequest = false,
        supportsDisassembleRequest = true,
        supportsCancelRequest = false,
        supportsBreakpointLocationsRequest = false,
        supportsClipboardContext = false,
        supportsSteppingGranularity = false,
        supportsInstructionBreakpoints = false,
        supportsExceptionFilterOptions = false,
        supportsSingleThreadExecutionRequests = false,
    }
end

function commands.launch(args)
    launchCommand = args.program
    pause = true
    if not debugger.status() then
        debugger.step()
        debugger.unblock()
        print("Unblocked")
        debugger.waitForBreak()
        print("Done")
    end
    if launchCommand then debugger.setStartupCode("shell.run('" .. launchCommand .. "')") end
    debugger.run("coroutine.resume(coroutine.create(os.reboot))")
    debugger.continue()
    print("Continuing")
    debugger.waitForBreakAsync()
    pause = false
end

function commands.restart(args)
    pause = true
    if not debugger.status() then
        debugger.step()
        debugger.unblock()
        debugger.waitForBreak()
    end
    if launchCommand then debugger.setStartupCode("shell.run('" .. launchCommand .. "')") end
    debugger.run("coroutine.resume(coroutine.create(os.reboot))")
    debugger.continue()
    debugger.waitForBreakAsync()
    pause = false
end

function commands.disconnect(args)
    if args.terminateDebuggee then
        pause = true
        if not debugger.status() then
            debugger.step()
            debugger.unblock()
            debugger.waitForBreak()
        end
        debugger.run("coroutine.resume(coroutine.create(os.shutdown))")
        debugger.continue()
        debugger.waitForBreakAsync()
        pause = false
    elseif args.suspendDebuggee then
        if not debugger.status() then
            debugger.step()
            debugger.unblock()
        end
    else
        if debugger.status() then
            debugger.continue()
            debugger.waitForBreakAsync()
        end
    end
end

function commands.terminate(args)
    pause = true
    if not debugger.status() then
        debugger.step()
        debugger.unblock()
        debugger.waitForBreak()
    end
    debugger.run("coroutine.resume(coroutine.create(os.shutdown))")
    debugger.continue()
    debugger.waitForBreakAsync()
    pause = false
end

function commands.setBreakpoints(args)
    -- TODO
    return {breakpoints = textutils.empty_json_array}
end

function commands.setFunctionBreakpoints(args)
    -- TODO
    return {breakpoints = textutils.empty_json_array}
end

function commands.setExceptionBreakpoints(args)
    -- TODO
end

function commands.continue(args)
    if debugger.status() then
        debugger.continue()
        debugger.waitForBreakAsync()
    end
    return {allThreadsContinued = true}
end

function commands.next(args)
    if debugger.status() then
        debugger.step()
        debugger.waitForBreakAsync()
    end
end

function commands.stepIn(args)
    if debugger.status() then
        debugger.step()
        debugger.waitForBreakAsync()
    end
end

function commands.stepOut(args)
    if debugger.status() then
        debugger.stepOut()
        debugger.waitForBreakAsync()
    end
end

function commands.pause(args)
    if not debugger.status() then
        debugger.step()
        debugger.unblock()
    end
end

function commands.stackTrace(args)
    local stack = {}
    for i = args.startFrame or 0, (args.startFrame or 1) + (args.levels or math.huge) do
        local info = debugger.getInfo(i)
        if not info then break end
        stack[#stack+1] = {
            id = i,
            name = info.name,
            source = {
                name = info.short_src,
                path = info.source:gsub("^[@=]", ""),
            },
            line = info.currentline or 0,
            column = 0,
            instructionPointerReference = tostring(info.instruction),
        }
    end
    return {
        stackFrames = stack,
        totalFrames = #stack
    }
end

function commands.scopes(args)
    -- TODO
    return {scopes = textutils.empty_json_array}
end

function commands.variables(args)
    -- TODO
    return {variables = textutils.empty_json_array}
end

function commands.setVariable(args)
    -- TODO
    return {value = ""}
end

function commands.source(args, message)
    local file, err = fs.open(args.source.path, "r")
    if not file then
        sendMessage {type = "response", request_seq = message.seq, success = false, command = message.command, error = err}
        return false
    end
    local data = file.readAll()
    file.close()
    return {content = data}
end

function commands.threads(args)
    return {threads = {{id = 1, name = "Computer"}}}
end

function commands.loadedSources(args)
    -- TODO
    return {sources = textutils.empty_json_array}
end

function commands.evaluate(args)
    -- TODO
    return {result = "", variablesReference = 0}
end

function commands.setExpression(args)
    -- TODO
    return {value = ""}
end

function commands.exceptionInfo(args)
    return {
        exceptionId = debugger.getReason(),
        breakMode = "always",
        details = debugger.getReason(),
    }
end

function commands.disassemble(args)
    -- TODO
    return {instructions = textutils.empty_json_array}
end

parallel.waitForAny(function()
    local buffer = ""
    while true do
        local _, input = coroutine.yield("dap_input")
        print(input)
        buffer = buffer .. input
        while buffer:match "\r\n\r\n" do
            print("Parsing")
            local headers = {}
            while true do
                local stop = buffer:find("\r\n")
                local line = buffer:sub(1, stop - 1)
                buffer = buffer:sub(stop + 2)
                if line == "" then break end
                headers[line:match("^[^:]+")] = line:match(":%s*(.*)$")
            end
            if headers["Content-Length"] then
                local length = tonumber(headers["Content-Length"])
                while #buffer < length do
                    _, input = coroutine.yield("dap_input")
                    print(input)
                    buffer = buffer .. input
                end
                local data = buffer:sub(1, length)
                buffer = buffer:sub(length + 1)
                local message = textutils.unserializeJSON(data)
                nextSequence = message.seq + 1
                print(message.seq, message.type)
                if message.type == "request" then
                    local body
                    if commands[message.command] then body = commands[message.command](message.arguments, message) end
                    if body ~= false then sendMessage {type = "response", request_seq = message.seq, success = true, command = message.command, body = body} end
                    if message.command == "initialize" then sendMessage {type = "event", event = "initialized"}
                    elseif message.command == "launch" or message.command == "attach" then
                        sendMessage {type = "event", event = "process", body = {name = "CraftOS-PC", isLocalProcess = false, startMethod = message.command}}
                        sendMessage {type = "event", event = "thread", body = {reason = "started", threadId = 1}}
                    end
                elseif message.type == "response" then if responseWait[message.request_seq] then responseWait[message.request_seq](message) end
                elseif message.type == "event" then if events[message.event] then events[message.event](message.body, message) end end
                print("Finished command")
            end
        end
    end
end, function()
    debugger.waitForBreakAsync()
    while true do
        coroutine.yield("debugger_break")
        debugger.confirmBreak()
        print("Did break")
        if not pause then
            print("Sending message")
            sendMessage {
                type = "event",
                event = "stopped",
                body = {
                    reason = reasonMap[debugger.getReason()] or "exception",
                    description = debugger.getReason(),
                    text = debugger.getReason(),
                    threadId = 1,
                    allThreadsStopped = true,
                    -- TODO: hitBreakpointIds
                }
            }
        end
    end
end, function()
    while true do
        local _, text = coroutine.yield("debugger_print")
        sendMessage {
            event = "output",
            body = {
                category = "console",
                output = text
            }
        }
    end
end)

end)
if not ok then printError(err) end
debugger.continue()
while true do coroutine.yield() end
