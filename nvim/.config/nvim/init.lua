-- basic config
vim.o.ignorecase = true      -- case-insensitive search
vim.o.smartcase = true       -- ... unless you're explicit
vim.o.number = true          -- line numbers
vim.o.relativenumber = true  -- relative line numbers
vim.o.colorcolumn = "80"     -- line at 80 ch width
vim.o.cursorline = true      -- cursor line
vim.o.scrolloff = 8          -- keep 8 lines while scrolling
vim.o.updatetime = 100       -- update every 100ms
vim.o.autochdir = true       -- cwd follows file
vim.o.shiftwidth = 4         -- indent by 4 spaces
vim.o.tabstop = 4            -- tab = 4 spaces
vim.o.smarttab = true        -- indent smartly
vim.o.expandtab = true       -- tab expands into spaces
vim.o.splitbelow = true      -- new splits open below
vim.o.splitright = true      -- new splits open right
vim.o.winborder = "rounded"  -- rounded border
vim.o.winblend = 10          -- translucent floating windows

-- theme
vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd.colorscheme("lunaperche")
local set_colors = function()
    vim.cmd([[
    hi Normal       guibg=NONE ctermbg=NONE
    hi NonText      guibg=NONE ctermbg=NONE
    hi NormalFloat  guibg=NONE ctermbg=NONE
    hi VertSplit    guibg=NONE ctermbg=NONE
    hi FloatBorder  ctermfg=NONE ctermbg=NONE cterm=NONE
    hi StatusLine   gui=nocombine cterm=nocombine
    hi User1        gui=bold,reverse cterm=bold,reverse
    ]])
end
set_colors()

vim.api.nvim_create_augroup("colorscheme_change", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
    group = "colorscheme_change",
    callback = set_colors,
})

-- persistent undo
local data_dir = vim.fn.stdpath("data")
vim.o.undodir = data_dir .. "/undo"
vim.o.directory = data_dir .. "/swap//"
vim.o.undofile = true
vim.o.undolevels = 1000
vim.o.undoreload = 10000

-- use space as leader
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- remember last cursor pos in file
vim.api.nvim_create_augroup("rememberfilepos", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
    group = "rememberfilepos",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- command-line completion
vim.o.wildmode = "longest:full,full"

-- diagnostics
vim.diagnostic.enable = true
vim.diagnostic.config({
    virtual_lines = { current_line = true },
})

-- autocompletion
vim.o.complete = ".,o"
vim.o.completeopt = "fuzzy,menuone,noselect"
vim.o.autocomplete = true
vim.o.pumheight = 12

-- netrw improvements
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3 -- tree style listing
vim.g.netrw_browse_split = 3 -- split horizontal
vim.g.netrw_preview = 1 -- preview in vertical split

-- keymaps
-- x does not yank
vim.keymap.set({ "n", "v" }, "x", '"_x')
vim.keymap.set({ "n", "v" }, "X", '"_X')

-- Y works like C/D
vim.keymap.set("n", "Y", "y$")

-- yank/paste from system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<leader>Y", '"+Y')
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P')

-- resource config
vim.keymap.set("n", "<leader>x", ":Update<cr> :source<cr>")

-- quick bol/eol
vim.keymap.set({ "n", "v" }, "H", "^")
vim.keymap.set({ "n", "v" }, "L", "$")

-- wrap current paragraph
vim.keymap.set("n", "<C-q>", "gqip", { silent = true })

-- quick netrw
vim.keymap.set("n", "-", ":Ex<cr>", { silent = true })

-- quick-edit all like this (budget multicursor)
vim.keymap.set("n", "<C-s>", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<left><left><left>")

-- quick macro
vim.keymap.set("n", "Q", "@q")

-- dot repeat / macro on a visually select lines
vim.keymap.set("x", ".", ":norm .<cr>")
vim.keymap.set("x", "Q", ":norm @q<cr>")

-- move lines in visual
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")

-- preserve cursor position when joining lines
vim.keymap.set("n", "J", "mzJ`z")

-- quick buffer switching
vim.keymap.set("n", "<leader><leader>", ":b#<cr>", { silent = true })

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

vim.keymap.set("v", "<leader>a", ":Align ")
vim.keymap.set("v", "<leader>A", ":Align<cr>")

-- highlight yanked areas
vim.api.nvim_create_augroup("highlight_yanked", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = "highlight_yanked",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- statusline
vim.o.statusline = table.concat({
    "%1*",
    "%(%{&filetype!='help'?'  '.bufnr('%'):''} %)",
    "%*",
    " ‹‹ %f%r%m ›› ",
    "%=",
    "   %{toupper(&ft)}   ",
    "%1*",
    "  %2P %4l:%02v ",
})

-- plugins
vim.pack.add({
    "https://github.com/tpope/vim-rsi",                   -- emacs motions in insert mode
    "https://github.com/tpope/vim-sleuth",                -- auto-detect indentation from file
    "https://github.com/tpope/vim-fugitive",              -- git client
    "https://github.com/ibhagwan/fzf-lua",                -- fuzzy finder
    "https://github.com/mattn/emmet-vim",                 -- html/xml quick inserts
    "https://github.com/kylechui/nvim-surround",          -- motion for surrounding text
    "https://github.com/gbprod/substitute.nvim",          -- motion to replace text
    "https://github.com/neovim/nvim-lspconfig",           -- lsp config data
    "https://github.com/mason-org/mason.nvim",            -- lsp server install helper
    "https://github.com/mason-org/mason-lspconfig.nvim",  -- ...with config data
})
vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
end, {})

-- some plugins need enabling
require("nvim-surround").setup()

-- subsitute bindings
local substitute = require("substitute")
substitute.setup()
vim.keymap.set("n", "s", substitute.operator)
vim.keymap.set("n", "ss", substitute.line)
vim.keymap.set("n", "S", substitute.eol)
vim.keymap.set("x", "s", substitute.visual)

-- lsp setup and bindings
require("mason").setup()
require("mason-lspconfig").setup()

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            -- tell lsp where the vim runtime lives
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
        },
    },
})

vim.keymap.set("n", "gr=", vim.lsp.buf.format, { silent = true })

-- fzf setup and bindings
local fzf = require("fzf-lua")
local is_git_repo = function()
    local ok, res = pcall(vim.fn.system, "git rev-parse --is-inside-work-tree")
    if not ok then
        return false
    end
    return vim.trim(res) == "true"
end

local files_or_git_files = function()
    if is_git_repo() then
        fzf.git_files()
    else
        fzf.files()
    end
end

vim.keymap.set("n", "<leader>f", files_or_git_files, { silent = true })
vim.keymap.set("n", "<leader>F", fzf.files, { silent = true })
vim.keymap.set("n", "<leader>b", fzf.buffers, { silent = true })
vim.keymap.set("n", "<leader>m", fzf.marks, { silent = true })
vim.keymap.set("n", "<leader>j", fzf.jumps, { silent = true })
vim.keymap.set("n", "<leader>l", fzf.blines, { silent = true })
vim.keymap.set("n", "<leader>L", fzf.lines, { silent = true })
vim.keymap.set("n", "<leader>/", fzf.live_grep_native, { silent = true })
vim.keymap.set("v", "<leader>/", fzf.grep_visual, { silent = true })

-- git bindings
vim.keymap.set("n", "<leader>gg", ":tab Git<cr>", { silent = true })
vim.keymap.set("n", "<leader>gb", ":Git blame<cr>", { silent = true })
vim.keymap.set("n", "<leader>gc", fzf.git_commits, { silent = true })
vim.keymap.set("n", "<leader>gf", fzf.git_diff, { silent = true })

vim.lsp.config("vtsls", {
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
    settings = {
        vtsls = {
            tsserver = {
                globalPlugins = {
                    {
                        name = "@vue/typescript-plugin",
                        languages = { "vue" },
                        configNamespace = "typescript",
                        location = vim.fn.stdpath("data")
                            .. "/mason/-ackages/vue-language-server/node_modules/@vue/language-server",
                    },
                },
            },
        },
    },
})
