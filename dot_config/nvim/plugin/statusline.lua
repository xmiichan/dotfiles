-- statusline
local jj_root = require("mii.jj_root")

_G.Statusline = {
    jumplist_pos = function()
        local result = vim.fn.getjumplist()
        local jl, idx = result[1], result[2]
        if #jl == 0 then return "" end
        return string.format(" %d/%d ", idx + 1, #jl)
    end,

    jj = function()
        local now = vim.uv.now()
        if not Statusline._t or now - Statusline._t > 2000 then
            Statusline._t = now
            vim.system({ "jj", "log", "--no-graph", "-r", "@", "-T",
                'change_id.shortest(8) ++ if(conflict, "!", "")'
                .. ' ++ if(divergent, "?", "") ++ if(empty, "", "+")' },
                { text = true },
                vim.schedule_wrap(function(r)
                    vim.g.jj_change = r.code == 0 and vim.trim(r.stdout) or ""
                end))
        end
        local ret = vim.g.jj_change and "[jj:" .. vim.g.jj_change .. "]" or ""
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

vim.o.statusline = table.concat({
    "%*",
    "%(%{&filetype!='help'?'  '.bufnr('%'):''} %)",
    "%1*",
    " ‹‹ %f%r%m ›› ",
    "%{v:lua.Statusline.vcs()}",
    "%=",
    "   %{toupper(&ft)}   ",
    "%{v:lua.Statusline.jumplist_pos()} ",
    "%*",
    "  %2P %4l:%02v ",
})
