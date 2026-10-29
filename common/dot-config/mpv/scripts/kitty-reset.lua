mp.register_event("shutdown", function()
    if mp.get_property("vo") == "kitty" then
        local f = io.open("/dev/tty", "w")
        if f then
            f:write("\027c")
            f:close()
        end
    end
end)
