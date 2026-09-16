return function(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr or 0)
    local dir = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
    return vim.fs.root(dir, ".jj") ~= nil
end
