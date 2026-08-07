-- statusline
_G.Statusline = {
    jumplist_pos = function()
        local result = vim.fn.getjumplist()
        local jl, idx = result[1], result[2]
        if #jl == 0 then return "" end
        return string.format(" %d/%d ", idx + 1, #jl)
    end,

    chezmoi_flag = function()
        return vim.b.chezmoi_managed and "cz" or ""
    end,
}

vim.o.statusline = table.concat({
    "%*",
    "%(%{&filetype!='help'?'  '.bufnr('%'):''} %)",
    "%1*",
    " ‹‹ %f%r%m ›› ",
    "%{exists('*FugitiveStatusline')?FugitiveStatusline():''}",
    "%=",
    "%{v:lua.Statusline.chezmoi_flag()}",
    "   %{toupper(&ft)}   ",
    "%{v:lua.Statusline.jumplist_pos()} ",
    "%*",
    "  %2P %4l:%02v ",
})
