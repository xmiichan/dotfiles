-- transparent editing of encrypted files

local function pipe(cmd, stdin)
    local res = vim.system(cmd, { stdin = stdin, text = false }):wait()
    if res.code ~= 0 then
        local err = vim.trim(res.stderr or "")
        error(err ~= "" and err or ("exit " .. res.code), 0)
    end
    return res.stdout
end

-- age support currently only for chezmoi
-- use gpg for anything else
local age_config
local function age()
    if age_config == nil then
        local res = vim.system({
            "chezmoi", "execute-template",
            "{{ .chezmoi.config.age.recipient }}\n"
            .. "{{ .chezmoi.config.age.identity }}",
        }):wait()
        local out = vim.split(vim.trim(res.stdout or ""), "\n")
        age_config = (res.code == 0 and #out == 2 and out[1] ~= "")
            and { recipient = out[1], identity = out[2] }
            or false
    end
    return assert(age_config, "no age settings in the chezmoi config")
end

local function gpg_decrypt(file)
    local ok, out = pcall(pipe, {
        "gpg", "--batch", "--quiet", "--pinentry-mode", "error",
        "--decrypt", file,
    })
    if ok then return out end

    vim.cmd("redraw")
    local pass = vim.fn.inputsecret(
        "Passphrase for " .. vim.fn.fnamemodify(file, ":t") .. ": ")
    vim.cmd("redraw")

    return pipe({
        "gpg", "--batch", "--quiet", "--pinentry-mode", "loopback",
        "--passphrase-fd", "0", "--decrypt", file,
    }, pass)
end

local specs = {
    {
        pattern = "*.age",
        decrypt = function(_, raw)
            return pipe(
                { "age", "--decrypt", "--identity", age().identity }, raw
            )
        end,
        encrypt = function(_, plain)
            return pipe(
                { "age", "--encrypt", "--recipient", age().recipient }, plain
            )
        end,
    },
    {
        pattern = { "*.gpg", "*.pgp", "*.asc" },
        decrypt = function(file)
            return gpg_decrypt(file)
        end,
        encrypt = function(_, plain)
            return pipe({
                "gpg", "--batch", "--quiet", "--encrypt",
                "--default-recipient-self",
            }, plain)
        end,
    },
}

local function detect_filetype(buf, file)
    local plain = file:gsub("%.%w+$", "")
    vim.bo[buf].filetype =
        vim.filetype.match({ filename = plain, buf = buf }) or ""
end

local function fail(buf, msg)
    vim.b[buf].crypt_failed = true
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true
    vim.notify(msg, vim.log.levels.ERROR)
end

local function read(spec, args)
    local raw
    local fd = io.open(args.file, "rb")
    if fd then
        raw = fd:read("*a")
        fd:close()
    end
    if not raw or raw == "" then
        return detect_filetype(args.buf, args.file)
    end

    local ok, out = pcall(spec.decrypt, args.file, raw)
    if not ok then
        return fail(args.buf, "crypt: decrypt failed: " .. out)
    end

    local lines = vim.split(out, "\n")
    vim.bo[args.buf].endofline = lines[#lines] == ""
    if vim.bo[args.buf].endofline then
        table.remove(lines)
    end

    vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
    vim.bo[args.buf].modified = false
    detect_filetype(args.buf, args.file)
end

local function write(spec, args)
    -- an empty buffer here means decryption failed, not an empty file
    if vim.b[args.buf].crypt_failed then
        return vim.notify(
            "crypt: refusing to overwrite an undecrypted file",
            vim.log.levels.ERROR
        )
    end

    local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
    local plain = table.concat(lines, "\n")
    if vim.bo[args.buf].endofline then
        plain = plain .. "\n"
    end

    local ok, out = pcall(spec.encrypt, args.file, plain)
    if not ok then
        return vim.notify(
            "crypt: encrypt failed: " .. out, vim.log.levels.ERROR
        )
    end

    local fd, err = io.open(args.file, "wb")
    if not fd then
        return vim.notify("crypt: " .. err, vim.log.levels.ERROR)
    end
    fd:write(out)
    fd:close()
    vim.bo[args.buf].modified = false
end

vim.api.nvim_create_augroup("transparent_crypt", { clear = true })

for _, spec in ipairs(specs) do
    -- BufReadCmd supersedes BufReadPre and BufNewFile for these patterns
    vim.api.nvim_create_autocmd({ "BufNew", "BufReadCmd" }, {
        group = "transparent_crypt",
        pattern = spec.pattern,
        callback = function(args)
            vim.bo[args.buf].swapfile = false
            vim.bo[args.buf].undofile = false
            if args.event == "BufReadCmd" then
                read(spec, args)
            end
        end,
    })

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        group = "transparent_crypt",
        pattern = spec.pattern,
        callback = function(args)
            write(spec, args)
        end,
    })
end
