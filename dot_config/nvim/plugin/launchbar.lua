-- launchbar support
if vim.uv.os_uname().sysname == 'Darwin' then
    local send_to_lb = function()
        vim.cmd('normal! "zy')
        local text = vim.fn.getreg('z')
        local escaped = text:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n')

        local script = [[tell application "LaunchBar"
        set selection to "]] .. escaped .. [["
        activate
        end tell]]

        vim.fn.system({ 'osascript', '-e', script })
    end

    vim.keymap.set("v", "<C-j>", send_to_lb)
    vim.keymap.set("n", "<C-j>", function()
        vim.cmd('normal! viw')
        send_to_lb()
    end)
end
