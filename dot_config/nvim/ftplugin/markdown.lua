vim.opt_local.spell = true
vim.opt_local.conceallevel = 2
vim.opt_local.autocomplete = false
vim.opt_local.complete:append("kspell")

vim.keymap.set({ "n", "v", "o" }, "j", function()
    return vim.v.count > 0 and "j" or "gj"
end, { expr = true, buffer = true })

vim.keymap.set({ "n", "v", "o" }, "k", function()
    return vim.v.count > 0 and "k" or "gk"
end, { expr = true, buffer = true })

vim.keymap.set({ "n", "v", "o" }, "0", function()
    return vim.v.count > 0 and "0" or "g0"
end, { expr = true, buffer = true })

vim.keymap.set({ "n", "v", "o" }, "^", function()
    return vim.v.count > 0 and "^" or "g^"
end, { expr = true, buffer = true })

vim.keymap.set({ "n", "v", "o" }, "$", function()
    return vim.v.count > 0 and "$" or "g$"
end, { expr = true, buffer = true })

vim.keymap.set("n", "V", function()
    return vim.v.count > 0 and "V" or "g0vg$"
end, { expr = true, buffer = true })

-- manual wrapping, respecting visual lines
local function begins_joinable(line)
    local s = vim.fn.getline(line)
    return s:match("^%s*[-*+]%s") or s:match("^%s*%d+[.)]%s") or s:match("^%s*>")
end

local function is_codeblock_delim(str)
    return str:match("^%s*[`~][`~][`~]")
end

local function is_unjoinable(line)
    local str = vim.fn.getline(line)
    return str:match("^%s*$") or str:match("^%s*#") or str:match("^%s*|") or is_codeblock_delim(str)
end

local function is_in_codeblock(line)
    local n = 0
    for _, str in ipairs(vim.api.nvim_buf_get_lines(0, 0, line, false)) do
        if is_codeblock_delim(str) then
            n = n + 1
        end
    end
    return n % 2 == 1
end

vim.keymap.set("n", "<C-q>", function()
    local cur, eof = vim.fn.line("."), vim.fn.line("$")
    if is_unjoinable(cur) or is_in_codeblock(cur) then
        return
    end
    local first, stop = cur, cur
    while first > 1 and not begins_joinable(first) and not is_unjoinable(first - 1) do
        first = first - 1
    end
    while stop < eof and not is_unjoinable(stop + 1) and not begins_joinable(stop + 1) do
        stop = stop + 1
    end
    if stop > first then
        vim.cmd(("silent %=,%djoin"):format(first, stop))
    end
end, { buffer = true })

-- break undo after punctuation
for _, ch in ipairs({ ".", "!", "?", ",", ";", ":" }) do
    vim.keymap.set("i", ch, ch .. "<C-g>u", { buffer = true })
end

vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.cursorlineopt = "screenline"
vim.opt_local.breakindentopt = "list:-1"

if vim.fn.exists(":Wrapwidth") == 2 then
    vim.cmd("Wrapwidth 80")
    vim.schedule(function()
        vim.cmd("Wrapwidth! 80")
    end)
end
