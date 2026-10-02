-- statusline
_G.Statusline = {
    spell = function()
        return vim.wo.spell and '/SPELL' or ''
    end,

    lsp = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        return #clients > 0 and '/LSP' or ''
    end,

    vcs = function()
        local jj_cmd = vim.system(
            { "jj", "log", "-r", "heads(::@ & bookmarks())", "--no-graph", "-T", "bookmarks" },
            { text = true}
        ):wait()

        if jj_cmd.code == 0 then
            local jj_changeid = vim.system(
                { "jj", "log", "-r", "@", "--no-graph", "-T", "change_id.shortest()" },
                { text = true}
            ):wait()
            return " 󰜛 " .. vim.trim(jj_cmd.stdout) .. " " .. vim.trim(jj_changeid.stdout)
        end

        local git_cmd = vim.system(
            { "git", "rev-parse", "--abbrev-ref", "HEAD" },
            { text = true}
        ):wait()
        return git_cmd.code == 0 and "  " .. vim.trim(git_cmd.stdout) or ""
    end,
}

vim.api.nvim_set_hl(0, 'User1',
    { ctermfg = 3, ctermbg = 'NONE', fg = 'orange', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'User2', { bold = true })

vim.o.laststatus = 3
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
