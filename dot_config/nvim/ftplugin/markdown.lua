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
