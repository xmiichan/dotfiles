-- basic config
vim.o.ignorecase = true     -- case-insensitive search
vim.o.smartcase = true      -- ... unless you're explicit
vim.o.number = true         -- line numbers
vim.o.relativenumber = true -- relative line numbers
vim.o.colorcolumn = "80"    -- line at 80 ch width
vim.o.cursorline = true     -- cursor line
vim.o.scrolloff = 8         -- keep 8 lines while scrolling
vim.o.updatetime = 100      -- update every 100ms
vim.o.autochdir = true      -- cwd follows file
vim.o.shiftwidth = 4        -- indent by 4 spaces
vim.o.tabstop = 4           -- tab = 4 spaces
vim.o.smarttab = true       -- indent smartly
vim.o.expandtab = true      -- tab expands into spaces
vim.o.linebreak = true      -- wrap at word boundaries
vim.o.breakindent = true    -- wrapped lines keep indent
vim.o.confirm = true        -- prompt to save on :q/:e
vim.o.virtualedit = "block" -- select past EOL in block mode
vim.o.splitbelow = true     -- new splits open below
vim.o.splitright = true     -- new splits open right
vim.o.title = true          -- set terminal title
vim.o.winborder = "rounded" -- rounded border
vim.o.pumborder = "rounded" -- ... also for popups

-- folding
_G.mii = _G.mii or {}
mii.foldexpr = require('mii.foldexpr')
vim.o.foldlevelstart = 99  -- start unfolded
vim.o.foldmethod = 'expr'
vim.o.foldminlines = 0     -- Allow closing even 1-line folds.
vim.o.foldexpr = 'v:lua.mii.foldexpr(v:lnum)'
vim.o.fillchars = 'eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:'

vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'v:lua.mii.foldexpr(v:lnum)'
    end,
})

vim.keymap.set("n", "+", "za")

-- theme
vim.o.termguicolors = true
vim.o.background = "dark"

local set_colors = function()
    vim.cmd([[
    hi Normal guibg=NONE ctermbg=NONE
    hi PMenu  guibg=NONE ctermbg=NONE
    hi! link FloatBorder Normal
    ]])
end

vim.api.nvim_create_augroup("colorscheme_change", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
    group = "colorscheme_change",
    callback = set_colors,
})

vim.cmd.colorscheme("catppuccin")

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
            pcall(function() vim.api.nvim_win_set_cursor(0, mark) end)
        end
    end,
})

-- make directory on write if it does not exist
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        -- Skip for Oil buffers or unnamed buffers
        if vim.bo.filetype == "oil" or vim.api.nvim_buf_get_name(0) == "" then
            return
        end

        local dir = vim.fn.fnamemodify(args.file, ":p:h")
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end
    end,
})

-- command-line completion
vim.o.wildmode = "longest:full,full"

-- diagnostics
vim.diagnostic.config({
    virtual_lines = { current_line = true },
})

-- autocompletion
vim.o.complete = ".,o"
vim.o.completeopt = "fuzzy,menuone,noselect"
vim.o.autocomplete = true
vim.o.pumheight = 12

vim.keymap.set("i", "<Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })

-- netrw improvements
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3    -- tree style listing
vim.g.netrw_browse_split = 3 -- split horizontal
vim.g.netrw_preview = 1      -- preview in vertical split

-- keymaps
-- x does not yank
vim.keymap.set({ "n", "v" }, "x", '"_x')
vim.keymap.set({ "n", "v" }, "X", '"_X')

-- Y works like C/D
vim.keymap.set("n", "Y", "y$")

-- yank and comment in one go
vim.keymap.set("n", "yc", "yygccp", { remap = true })
vim.keymap.set("v", "Y", "ygvgc`>p", { remap = true })

-- yank/paste from system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<leader>Y", '"+Y', { remap = true })
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P')

-- diff quickies
vim.keymap.set("n", "dol", ":diffget //2<cr>", { silent = true })
vim.keymap.set("n", "dor", ":diffget //3<cr>", { silent = true })

-- re-source config
vim.keymap.set("n", "<leader>x", ":Update<cr> :source<cr>")

-- quick bol/eol
vim.keymap.set({ "n", "v" }, "H", "^")
vim.keymap.set({ "n", "v" }, "L", "$")

-- wrap current paragraph
vim.keymap.set("n", "<C-q>", "mzgqip`z", { silent = true })

-- quick netrw
vim.keymap.set("n", "-", ":Ex<cr>", { silent = true })

-- quick-edit all like this (budget multicursor)
vim.keymap.set("n", "<C-s>",
    ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<left><left><left>")

-- quick macro
vim.keymap.set("n", "Q", "@q")

-- dot repeat / macro on a visually select lines
vim.keymap.set("x", ".", ":norm .<cr>")
vim.keymap.set("x", "Q", ":norm @q<cr>")

-- quick splits
vim.keymap.set("n", "<leader>ss", ":split<cr>")
vim.keymap.set("n", "<leader>sv", ":vsplit<cr>")

-- move lines in visual
vim.keymap.set("x", "<C-n>", ":m '>+1<cr>gv=gv")
vim.keymap.set("x", "<C-p>", ":m '<-2<cr>gv=gv")

-- preserve cursor position when joining lines
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "gJ", "mzkJ`z")

-- quick buffer switching
vim.keymap.set("n", "<leader><leader>", ":b#<cr>", { silent = true })

-- open diagnostic window
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { silent = true })

-- readline style motions in insert mode
vim.keymap.set({ "i", "c" }, "<C-b>", "<Left>")
vim.keymap.set({ "i", "c" }, "<C-f>", "<Right>")
vim.keymap.set({ "i", "c" }, "<C-a>", "<Home>")
vim.keymap.set({ "i", "c" }, "<C-e>", "<End>")
vim.keymap.set({ "i", "c" }, "<C-p>", "<Up>")
vim.keymap.set({ "i", "c" }, "<C-n>", "<Down>")
vim.keymap.set({ "i", "c" }, "<M-b>", "<C-Left>")
vim.keymap.set({ "i", "c" }, "<M-f>", "<C-Right>")
vim.keymap.set({ "i", "c" }, "<M-p>", "<C-p>")
vim.keymap.set({ "i", "c" }, "<M-n>", "<C-n>")

-- highlight yanked areas
vim.api.nvim_create_augroup("highlight_yanked", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = "highlight_yanked",
    callback = function()
        vim.hl.hl_op({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- plugins
local plugins = {
    "https://github.com/tpope/vim-sleuth",               -- auto-detect indentation from file
    "https://github.com/airblade/vim-rooter",            -- auto-detect pwd
    "https://github.com/tpope/vim-fugitive",             -- git client
    "https://github.com/lewis6991/gitsigns.nvim",        -- git gutter
    "https://github.com/vim-scripts/regreplop.vim",      -- replace operator on <s>
    "https://github.com/ibhagwan/fzf-lua",               -- fuzzy finder
    "https://github.com/stevearc/oil.nvim",              -- file browser on steroids
    "https://github.com/folke/flash.nvim",               -- quick jump
    "https://github.com/kylechui/nvim-surround",         -- motion for surrounding text
    "https://github.com/windwp/nvim-autopairs",          -- auto-close brackets
    "https://github.com/tpope/vim-endwise",              -- ... and keywords
    "https://github.com/mattn/emmet-vim",                -- html/xml quick inserts
    "https://github.com/hat0uma/csvview.nvim",           -- pretty csv files
    "https://github.com/neovim/nvim-lspconfig",          -- lsp config data
    "https://github.com/mason-org/mason.nvim",           -- lsp server install helper
    "https://github.com/mason-org/mason-lspconfig.nvim", -- ... with config data
    "https://github.com/aserowy/tmux.nvim",              -- tmux integrations
    "https://github.com/alker0/chezmoi.vim",             -- chezmoi template support
    "https://github.com/junegunn/goyo.vim",              -- distraction-free writing
    "https://github.com/junegunn/limelight.vim",         -- ... and paragraph highlighting
}

vim.o.packlockfile = vim.fs.joinpath(
    vim.fn.stdpath("config"), "nvim-pack-lock.json")
vim.pack.add(plugins)

vim.g.rooter_resolve_links = 1

-- regreplop: replace with register
vim.keymap.set("n", "cr", "<Plug>ReplaceMotion", { silent = true })
vim.keymap.set("n", "crr", "<Plug>ReplaceLine", { silent = true })
vim.keymap.set("n", "cR", "cr$", { remap = true, silent = true })
vim.keymap.set("x", "cr", "<Plug>ReplaceVisual", { silent = true })

-- flash: quick jump
require("flash").setup({
    prompt = { enabled = false },
    modes = {
        search = { enabled = false },
        char = { enabled = false },
    },
})
vim.keymap.set({ "n", "x", "o" }, "s", require("flash").jump)

require("nvim-surround").setup()
require("nvim-autopairs").setup()
require("csvview").setup({
    view = {
        display_mode = "border",
    },
    keymaps = {
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "csv",
    command = "CsvViewEnable",
})

require("oil").setup({
    float = {
        padding = 10,
        max_width = 0,
        max_height = 0,
        border = "rounded",
        win_options = {
            winblend = 0,
        },
    },
})
vim.keymap.set("n", "-", require("oil").open_float)

local is_git_repo = function()
    local ok, res = pcall(vim.fn.system, "git rev-parse --is-inside-work-tree")
    if not ok then return false end
    return vim.trim(res) == "true"
end

local files_or_git_files = function()
    if is_git_repo() then
        require("fzf-lua").git_files()
    else
        require("fzf-lua").files()
    end
end

vim.keymap.set("n", "<leader>f", files_or_git_files, { silent = true })
vim.keymap.set("n", "<leader>F", require("fzf-lua").files, { silent = true })
vim.keymap.set("n", "<leader>b", require("fzf-lua").buffers, { silent = true })
vim.keymap.set("n", "<leader>m", require("fzf-lua").marks, { silent = true })
vim.keymap.set("n", "<leader>j", require("fzf-lua").jumps, { silent = true })
vim.keymap.set("n", "<leader>/", function()
    require("fzf-lua").blines({ previewer = false })
end, { silent = true })
vim.keymap.set({ "n", "x" }, "<leader>r", function()
    require("fzf-lua").registers({
        winopts = {
            relative = "cursor",
            row = 1,
            col = 0,
            height = 0.30,
            width = 0.40,
            preview = { hidden = true },
        },
    })
end, { silent = true })

local rg_opts = "--hidden --column --line-number --no-heading"
    .. " --color=always --smart-case -g '!.git/'"
vim.keymap.set("n", "<leader>;", function()
    require("fzf-lua").live_grep({ rg_opts = rg_opts })
end, { silent = true })
vim.keymap.set("v", "<leader>;", function()
    require("fzf-lua").grep_visual({ rg_opts = rg_opts })
end, { silent = true })

-- point Fugitive to the git repo behind a symlink
local function fugitive_resolve()
    local real = vim.fn.resolve(vim.fn.expand("%:p"))
    local dir = vim.fn.fnamemodify(real, ":h")
    local handle = io.popen(
        "git -C " .. vim.fn.shellescape(dir)
        .. " rev-parse --git-dir 2>/dev/null"
    )
    if not handle then return end
    local result = vim.trim(handle:read("*a"))
    handle:close()
    if result == "" then return end
    if not result:match("^/") then
        result = dir .. "/" .. result
    end
    vim.b.git_dir = result
end

-- git bindings
vim.keymap.set("n", "<leader>gg", function()
    fugitive_resolve()
    vim.cmd("Git")
end, { silent = true })
vim.keymap.set("n", "<leader>gb", function()
    fugitive_resolve()
    vim.cmd("Git blame")
end, { silent = true })
vim.keymap.set("n", "<leader>gc", require("fzf-lua").git_commits,
    { silent = true })
vim.keymap.set("n", "<leader>gC", require("fzf-lua").git_bcommits,
    { silent = true })
vim.keymap.set("n", "<leader>gf", require("fzf-lua").git_diff, { silent = true })

-- distraction-free writing
vim.g.limelight_conceal_ctermfg = 'grey'
vim.g.limelight_conceal_guifg = 'grey'

vim.api.nvim_create_autocmd("User", {
    pattern = "GoyoEnter",
    command = "Limelight",
})

vim.api.nvim_create_autocmd("User", {
    pattern = "GoyoLeave",
    command = "Limelight!",
})

vim.keymap.set("n", "<leader>G", ":Goyo<cr>")

