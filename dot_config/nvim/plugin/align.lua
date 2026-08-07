-- regex-based alignment
local function align_section(line1, line2, regex)
    local extra = 1
    local sep = regex == "" and "=" or regex
    local maxpos = 0
    local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

    for _, line in ipairs(lines) do
        local pos = string.find(line, " *" .. vim.pesc(sep))
        if pos and maxpos < pos then
            maxpos = pos
        end
    end

    for i, line in ipairs(lines) do
        local beg, rest = string.match(line, "(.-) *(" .. vim.pesc(sep) .. ".*)")
        if beg and rest then
            local spaces = string.rep(" ", maxpos - string.len(beg) + extra)
            lines[i] = beg .. spaces .. rest
        end
    end

    vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
end

vim.api.nvim_create_user_command("Align", function(opts)
    align_section(opts.line1, opts.line2, opts.args or "")
end, { nargs = "?", range = true })

vim.keymap.set("x", "<leader>a", ":Align ")
vim.keymap.set("x", "<leader>A", ":Align<cr>")
