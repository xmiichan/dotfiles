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

vim.keymap.set("n", "<M-h>", tmux.move_left)
vim.keymap.set("n", "<M-j>", tmux.move_bottom)
vim.keymap.set("n", "<M-k>", tmux.move_top)
vim.keymap.set("n", "<M-l>", tmux.move_right)

vim.keymap.set("n", "<M-H>", tmux.resize_left)
vim.keymap.set("n", "<M-J>", tmux.resize_bottom)
vim.keymap.set("n", "<M-K>", tmux.resize_top)
vim.keymap.set("n", "<M-L>", tmux.resize_right)

vim.keymap.set("n", "<C-M-h>", tmux.swap_left)
vim.keymap.set("n", "<C-M-j>", tmux.swap_bottom)
vim.keymap.set("n", "<C-M-k>", tmux.swap_top)
vim.keymap.set("n", "<C-M-l>", tmux.swap_right)
