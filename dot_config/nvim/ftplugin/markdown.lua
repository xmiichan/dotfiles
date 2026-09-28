vim.opt_local.textwidth = 80
vim.opt_local.formatoptions:append({ "t", "a" })
vim.opt_local.conceallevel = 2

vim.opt_local.spell = true
vim.opt_local.autocomplete = false
vim.opt_local.complete:append("kspell")

-- break undo after punctuation
for _, ch in ipairs({ ".", "!", "?", ",", ";", ":" }) do
    vim.keymap.set("i", ch, ch .. "<C-g>u", { buffer = true })
end

-- don't autoformat in code fences
local function in_fence(buf)
    local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
    if not ok or not parser then
        return false
    end
    parser:parse()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local node = vim.treesitter.get_node({
        bufnr = buf,
        pos = { cursor[1] - 1, cursor[2] },
        ignore_injections = true,
    })
    while node do
        if node:type() == "fenced_code_block" then
            return true
        end
        node = node:parent()
    end
    return false
end

local buf = vim.api.nvim_get_current_buf()
local name = "markdown_fence_wrap_" .. buf
local group = vim.api.nvim_create_augroup(name, { clear = true })

vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, {
    group = group,
    buffer = buf,
    callback = function(args)
        if in_fence(args.buf) then
            vim.opt_local.formatoptions:remove({ "t", "a" })
        else
            vim.opt_local.formatoptions:append({ "t", "a" })
        end
    end,
})

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "")
    .. " | setlocal tw< fo< | autocmd! " .. name
