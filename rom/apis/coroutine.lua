local nativeCoroutine = coroutine
local coroutineList = {}

create = nativeCoroutine.create
wrap = nativeCoroutine.wrap
yield = nativeCoroutine.yield

function resume(coro, ...)
    table.insert(coroutineList, coro)
    local res = {nativeCoroutine.resume(coro, ...)}
    table.remove(coroutineList, #coroutineList)
    return table.unpack(res)
end

function running()
    return coroutineList[#coroutineList]
end

function status(coro)
    if coro == coroutineList[#coroutineList] then return "running" end
    for k,v in pairs(coroutineList) do if coro == v then return "normal" end end
    return nativeCoroutine.status(coro)
end