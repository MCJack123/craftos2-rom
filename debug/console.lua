multishell.setTitle(multishell.getCurrent(), "Console")
local w, h = term.getSize()
local win = window.create(term.current(), 1, 1, w, 9000)
local top = 1
local bottom = 1
local scrolling = false
term.redirect(win)
while true do
    local ev, p1 = os.pullEventRaw()
    if ev == "debugger_print" then 
        local lines = print(p1)
        bottom = math.min(bottom + lines, 9000)
        if not scrolling and bottom > h + 1 and top < 9000 - h then
            top = bottom - h
            win.reposition(1, 2-top)
        end
    elseif ev == "mouse_scroll" then
        if (p1 == -1 and top > 1) or (p1 == 1 and top < 9000 - h) then
            scrolling = top + h - 1 ~= bottom
            top = math.min(top + p1, 9000)
            win.reposition(1, 2-top)
        end
    end
end