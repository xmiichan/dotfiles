-- tmux integration
local tmux = require("tmux")
tmux.setup({
    navigation = {
        enable_default_keybindings = false,
    },
    resize = {
        enable_default_keybindings = false,
        resize_step_x = 5,
    },
    swap = {
        enable_default_keybindings = false,
    },
})

local modes = { "n", "t" }

vim.keymap.set(modes, "<M-h>", tmux.move_left)
vim.keymap.set(modes, "<M-j>", tmux.move_bottom)
vim.keymap.set(modes, "<M-k>", tmux.move_top)
vim.keymap.set(modes, "<M-l>", tmux.move_right)

vim.keymap.set(modes, "<M-H>", tmux.resize_left)
vim.keymap.set(modes, "<M-J>", tmux.resize_bottom)
vim.keymap.set(modes, "<M-K>", tmux.resize_top)
vim.keymap.set(modes, "<M-L>", tmux.resize_right)

vim.keymap.set(modes, "<C-M-h>", tmux.swap_left)
vim.keymap.set(modes, "<C-M-j>", tmux.swap_bottom)
vim.keymap.set(modes, "<C-M-k>", tmux.swap_top)
vim.keymap.set(modes, "<C-M-l>", tmux.swap_right)
