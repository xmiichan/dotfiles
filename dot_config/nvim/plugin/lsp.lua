require("mason").setup()

-- stylua is way too fucking opinionated
require("mason-lspconfig").setup({
    automatic_enable = { exclude = { "stylua" } },
})

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            -- tell lsp where the vim runtime lives
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
            format = {
                defaultConfig = {
                    indent_style = "space",
                    indent_size = "4",
                    max_line_length = "80",
                    align_continuous_inline_comment = "true",
                },
            },
        },
    },
})

vim.lsp.config("bashls", {
    filetypes = { "sh", "bash", "zsh" },
})

vim.keymap.set("n", "gr=", vim.lsp.buf.format, { silent = true })
