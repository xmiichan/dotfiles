-- chezmoi
---@type string?
local chezmoi_source = vim.trim(vim.fn.system("chezmoi source-path"))
if vim.v.shell_error ~= 0 then
    chezmoi_source = nil
end

local function chezmoi_apply()
    if vim.bo.modified then
        vim.cmd("write")
    end
    local file = vim.fn.resolve(vim.fn.expand("%:p"))
    local target = vim.trim(vim.fn.system({ "chezmoi", "target-path", file }))
    if vim.v.shell_error ~= 0 then
        vim.notify(target, vim.log.levels.ERROR)
        return
    end
    vim.system({ "chezmoi", "apply", target }, {}, function(res)
        vim.schedule(function()
            if res.code == 0 then
                vim.notify("chezmoi: applied " .. target)
            else
                vim.notify(
                    "chezmoi apply failed: " .. vim.trim(res.stderr or ""),
                    vim.log.levels.ERROR
                )
            end
        end)
    end)
end

if chezmoi_source then
    local prefix = chezmoi_source .. "/"
    vim.api.nvim_create_augroup("chezmoi_managed", { clear = true })
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        group = "chezmoi_managed",
        callback = function(args)
            local file = vim.fn.resolve(vim.fn.fnamemodify(args.file, ":p"))
            if file:sub(1, #prefix) ~= prefix then
                return
            end
            vim.b[args.buf].chezmoi_managed = true
            vim.keymap.set("n", "<leader>ca", chezmoi_apply, {
                buffer = args.buf,
                silent = true,
                desc = "chezmoi apply this file",
            })
        end,
    })
end
