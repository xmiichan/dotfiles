highlight clear

if exists("syntax_on")
    syntax reset
endif

set background=dark
let g:colors_name = "gruber"

let s:black  = ["#1C1C1C", "234"]
let s:blue   = ["#96A6C8", "110"]
let s:brown  = ["#AF875F", "137"]
let s:cyan   = ["#9FA99F", "151"]
let s:gray   = ["#333333", "235"]
let s:lgray  = ["#453D41", "235"]
let s:green  = ["#87D75F", "113"]
let s:red    = ["#FF5F5F", "203"]
let s:white  = ["#E4E4E4", "254"]
let s:yellow = ["#FFDD33", "220"]

let s:bold      = "bold"
let s:italic    = "italic"
let s:underline = "underline"
let s:undercurl = "undercurl"

let g:terminal_ansi_colors = [
    \ '#333333', '#F43841', '#73D936', '#FFDD33',
    \ '#96A6C8', '#9E95C7', '#95A99F', '#E4E4E4',
    \ '#453D41', '#F43841', '#73D936', '#FFDD33',
    \ '#96A6C8', '#9E95C7', '#95A99F', '#FFFFFF',
    \ ]

function! s:hl(group, attrs) abort
    if has_key(a:attrs, "fg")
        let a:attrs["guifg"] = a:attrs["fg"][0]
        let a:attrs["ctermfg"] = a:attrs["fg"][1]
        unlet a:attrs["fg"]
    endif

    if has_key(a:attrs, "bg")
        let a:attrs["guibg"] = a:attrs["bg"][0]
        let a:attrs["ctermbg"] = a:attrs["bg"][1]
        unlet a:attrs["bg"]
    endif

    if has_key(a:attrs, "style")
        let a:attrs["gui"] = a:attrs["style"]
        let a:attrs["cterm"] = a:attrs["style"]
        unlet a:attrs["style"]
    endif

    if has_key(a:attrs, "special")
        let a:attrs["guisp"] = a:attrs["special"][0]
        unlet a:attrs["special"]
    endif

    let l:defaults = { "guifg": "NONE", "guibg": "NONE", "gui": "NONE", "guisp": "NONE",
                     \ "ctermfg": "NONE", "ctermbg": "NONE", "cterm": "NONE" }
    call extend(l:defaults, a:attrs)

    let l:command = "highlight" . " " . a:group
    for name in keys(l:defaults)
        let l:command .= " " . name . "=" . l:defaults[name]
    endfor

    execute l:command
endfunction

" :source $VIMRUNTIME/syntax/hitest.vim
" :help group-name
" :help highlight-default

call s:hl("ColorColumn",    { "bg": s:gray })
call s:hl("Comment",        { "fg": s:brown })
call s:hl("Constant",       { "fg": s:cyan })
call s:hl("CursorLine",     { "bg": s:gray })
call s:hl("DiffAdd",        { "fg": s:green })
call s:hl("DiffChange",     { "fg": s:blue })
call s:hl("DiffDelete",     { "fg": s:red })
call s:hl("DiffText",       { "fg": s:blue, "style": s:underline })
call s:hl("Directory",      { "fg": s:blue })
call s:hl("EndOfBuffer",    { "fg": s:black })
call s:hl("Error",          { "fg": s:red })
call s:hl("ErrorMsg",       { "fg": s:red })
call s:hl("FoldColumn",     { "fg": s:brown, "bg": s:gray })
call s:hl("Folded",         { "fg": s:brown, "bg": s:gray })
call s:hl("Function",       { "fg": s:blue })
call s:hl("Identifier",     { "fg": s:white })
call s:hl("Ignore",         { "fg": s:black })
call s:hl("MatchParen",     { "fg": s:yellow, "style": s:bold })
call s:hl("MoreMsg",        { "fg": s:green })
call s:hl("NonText",        { "fg": s:blue })
call s:hl("Normal",         { "fg": s:white })
call s:hl("Pmenu",          { "fg": s:white })
call s:hl("PmenuKind",      { "fg": s:cyan })
call s:hl("PmenuExtra",     { "fg": s:lgray })
call s:hl("PmenuBorder",    { "fg": s:lgray })
call s:hl("Pmenu",          { "fg": s:white })
call s:hl("PmenuSbar",      { "bg": s:gray })
call s:hl("PmenuSel",       { "bg": s:gray, "style": s:bold })
call s:hl("PmenuThumb",     { "bg": s:lgray })
call s:hl("PreProc",        { "fg": s:cyan })
call s:hl("Question",       { "fg": s:blue })
call s:hl("Special",        { "fg": s:white })
call s:hl("SpecialChar",    { "fg": s:cyan })
call s:hl("SpecialComment", { "fg": s:brown })
call s:hl("SpecialKey",     { "fg": s:blue })
call s:hl("Statement",      { "fg": s:yellow, "style": s:bold })
call s:hl("StatusLine",     { "fg": s:white, "bg": s:black })
call s:hl("StatusLineNC",   { "fg": s:lgray, "bg": s:black })
call s:hl("User1",          { "fg": s:brown, "bg": s:black, "style": s:bold })
call s:hl("User2",          { "fg": s:white, "bg": s:black, "style": s:bold })
call s:hl("String",         { "fg": s:green })
call s:hl("Title",          { "fg": s:white })
call s:hl("Todo",           { "fg": s:blue, "style": s:bold })
call s:hl("Type",           { "fg": s:cyan })
call s:hl("Underlined",     { "style": s:underline })
call s:hl("VertSplit",      { "fg": s:gray })
call s:hl("WarningMsg",     { "fg": s:yellow })
call s:hl("WildMenu",       { "fg": s:black, "bg": s:yellow, "style": s:bold })
call s:hl("diffAdded",      { "fg": s:green })
call s:hl("diffRemoved",    { "fg": s:red })
call s:hl("diffSubname",    { "fg": s:blue })
call s:hl("LineNr",         { "fg": s:lgray })
call s:hl("CursorLineNr",   { "fg": s:yellow })
call s:hl("SignColumn",     { })
call s:hl("Search",         { "fg": s:black, "bg": s:brown })
call s:hl("IncSearch",      { "fg": s:black, "bg": s:yellow })
call s:hl("SpellBad",       { "style": s:undercurl, "special": s:red })
call s:hl("SpellCap",       { "style": s:undercurl, "special": s:blue })
call s:hl("SpellLocal",     { "style": s:undercurl, "special": s:green })
call s:hl("SpellRare",      { "style": s:undercurl, "special": s:cyan })
call s:hl("fugitiveHash",   { "fg": s:green })
