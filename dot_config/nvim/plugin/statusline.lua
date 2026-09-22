-- statusline
local jj_root = require("mii.jj_root")

_G.Statusline = {
    spell = function()
        return vim.wo.spell and '/SPELL' or ''
    end,

    lsp = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        return #clients > 0 and '/LSP' or ''
    end,

    jj = function()
        local now = vim.uv.now()
        if not Statusline._t or now - Statusline._t > 2000 then
            Statusline._t = now
            vim.system({ "jj", "log", "--no-graph", "-r",
                    "heads(::@ & bookmarks())", "-T", "bookmarks" },
                { text = true },
                vim.schedule_wrap(function(r)
                    local bookmark = r.code == 0 and vim.trim(r.stdout) or ""
                    if (not bookmark) or bookmark == "" then
                        vim.g.jj_bookmark = "root() "
                    else
                        vim.g.jj_bookmark = bookmark .. " "
                    end
                end))
            vim.system({ "jj", "log", "--no-graph", "-r", "@", "-T",
                    'change_id.shortest() ++ if(conflict, "!", "")'
                    .. ' ++ if(divergent, "?", "") ++ if(empty, "", "+")' },
                { text = true },
                vim.schedule_wrap(function(r)
                    vim.g.jj_change = r.code == 0 and vim.trim(r.stdout) or ""
                end))
        end
        local ret = vim.g.jj_change and
            "[jj(" .. vim.g.jj_bookmark .. vim.g.jj_change .. ")]" or ""
        return ret
    end,

    vcs = function()
        if jj_root() then
            return Statusline.jj()
        end
        if vim.fn.exists("*FugitiveStatusline") == 1 then
            return vim.fn.FugitiveStatusline()
        end
        return ""
    end,
}

vim.api.nvim_set_hl(0, 'User1',
    { ctermfg = 3, ctermbg = 'NONE', fg = 'orange', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'User2', { bold = true })

vim.o.statusline = table.concat({
    "%1*",
    "%(%{&filetype!='help'?'  '.bufnr('%'):''} %)",
    "%*",
    " ‹‹ %2*%t%r%w%m%* ›› ",
    "%{v:lua.Statusline.vcs()}",
    "%=",
    "%2*%{toupper(&ft)}%*",
    "%{v:lua.Statusline.spell()}",
    "%{v:lua.Statusline.lsp()}",
    "  ",
    "%1*",
    " ‹‹ %2l:%02v :: %2P ›› ",
})
