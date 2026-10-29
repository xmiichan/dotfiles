" tron-legacy theme for Vim 8+ by mii
" optmized for 256color terms, set notermguicolors
"
" based the Emacs theme by ianyepan
" <https:/github.com/ianyepan/tron-legacy-emacs-theme>

highlight clear

" back out if terminal has no 256color support, so it won't break in the
" linux console, you just get no colors
if &t_Co < 256 | finish | endif

if exists("syntax_on")
    syntax reset
endif

set background=dark
let g:colors_name = "tron-legacy"

" define colors
let s:bg0          = 16
let s:bg2          = 234
let s:bg3          = 236
let s:bg4          = 238
let s:hl_line      = 235
let s:fg0          = 109
let s:fg1          = 152
let s:fg4          = 195
let s:accent       = 231
let s:comment      = 60
let s:keyword      = 117
let s:const        = 159
let s:type         = 73
let s:str          = 67
let s:func         = 179
let s:warning      = 211
let s:red          = 125
let s:lightblue    = 153
let s:stline       = 24
let s:stline_dark  = 234
let s:green_bg     = 235
let s:red_bg       = 234
let s:blue_bg      = 17
let s:blue_bghl    = 17

" undercurl if supported, fall back to underline otherwise
let s:curl = empty(&t_Cs) ? 'underline' : 'undercurl'

" helper function to set everthing b/c i'm lazy
function! s:hi(group, opts = {}) abort
    let l:ul = has_key(a:opts, "ul") ? " ctermul=" . a:opts.ul : ""
    execute printf("highlight %s ctermfg=%s ctermbg=%s cterm=%s%s",
        \ a:group,
        \ get(a:opts, "fg", "NONE"),
        \ get(a:opts, "bg", "NONE"),
        \ get(a:opts, "attr", "NONE"),
        \ l:ul)
endfunction

call s:hi("Normal",     { "fg": s:fg1, "bg": s:bg0 })
call s:hi("Comment",    { "fg": s:comment, "attr": "italic" })
call s:hi("Conceal",    { "fg": s:comment })
call s:hi("Constant",   { "fg": s:const })
call s:hi("String",     { "fg": s:str })
call s:hi("Number",     { "fg": s:type })
call s:hi("Identifier", { "fg": s:fg1 })
call s:hi("Function",   { "fg": s:func })
call s:hi("Statement",  { "fg": s:keyword, "attr": "bold" })
call s:hi("PreProc",    { "fg": s:keyword })
call s:hi("Type",       { "fg": s:type })
call s:hi("Special",    { "fg": s:const })
call s:hi("Underlined", { "fg": s:const, "attr": "underline" })
call s:hi("Todo",       { "fg": s:type, "attr": "bold" })
call s:hi("Error",      { "fg": s:warning })

call s:hi("LineNr",       { "fg": s:comment })
call s:hi("CursorLineNr", { "fg": s:fg1 })
call s:hi("CursorLine",   { "bg": s:hl_line })
call s:hi("CursorColumn", { "bg": s:hl_line })
call s:hi("ColorColumn",  { "bg": s:bg2 })
call s:hi("SignColumn",   { })
call s:hi("NonText",      { "fg": s:bg4 })
call s:hi("Folded",       { "fg": s:comment, "bg": s:bg2 })
call s:hi("Visual",       { "bg": s:bg4 })
call s:hi("Search",       { "fg": s:accent, "bg": s:bg4 })
call s:hi("IncSearch",    { "fg": s:accent, "bg": s:bg4 })
call s:hi("MatchParen",   { "fg": s:accent, "bg": s:bg4, "attr": "bold" })
call s:hi("VertSplit",    { "fg": s:fg4 })
call s:hi("Directory",    { "fg": s:keyword })
call s:hi("Title",        { "fg": s:type, "attr": "bold" })
call s:hi("ErrorMsg",     { "fg": s:warning })
call s:hi("WarningMsg",   { "fg": s:func })

if exists('+pumborder')
    call s:hi("Pmenu",        { "fg": s:fg1 })
    call s:hi("PmenuBorder",  { "fg": s:fg1 })
else
    call s:hi("Pmenu",        { "fg": s:fg1, "bg": s:bg2 })
endif

call s:hi("PmenuSel",     { "fg": s:fg1, "bg": s:bg4 })
call s:hi("PmenuSbar",    { "bg": s:bg2 })
call s:hi("PmenuThumb",   { "bg": s:bg3 })

call s:hi("StatusLine",   { "fg": s:fg4, "bg": s:stline })
call s:hi("StatusLineNC", { "fg": s:fg0, "bg": s:stline_dark })
call s:hi("User1",        { "fg": s:fg4, "bg": s:stline, "attr": "bold" })
call s:hi("User2",        { "fg": s:fg4, "bg": s:stline_dark, "attr": "bold" })
call s:hi("User3",        { "fg": s:fg4, "bg": s:stline_dark })

call s:hi("TabLine",     { "bg": s:bg2 })
call s:hi("TabLineFill", { "bg": s:bg2 })
call s:hi("TabLineSel",  { "bg": s:bg4, "attr": "bold" })

call s:hi("GitGutterAdd",          { "fg": s:type })
call s:hi("GitGutterChange",       { "fg": s:str })
call s:hi("GitGutterDelete",       { "fg": s:red })
call s:hi("GitGutterChangeDelete", { "fg": s:red })

call s:hi("LspErrorText",              { "fg": s:warning })
call s:hi("LspWarningText",            { "fg": s:func })
call s:hi("LspInformationText",        { "fg": s:type })
call s:hi("LspHintText",               { "fg": s:keyword })
call s:hi("LspErrorVirtualText",       { "fg": s:warning })
call s:hi("LspWarningVirtualText",     { "fg": s:func })
call s:hi("LspInformationVirtualText", { "fg": s:type })
call s:hi("LspHintVirtualText",        { "fg": s:keyword })

call s:hi("DiffAdd",    { "fg": s:type, "bg": s:green_bg })
call s:hi("DiffDelete", { "fg": s:red, "bg": s:red_bg })
call s:hi("DiffChange", { "fg": s:keyword, "bg": s:blue_bg })
call s:hi("DiffText",   { "fg": s:lightblue, "bg": s:blue_bghl })

call s:hi("SpellBad",   { "attr": s:curl, "ul": s:warning })
call s:hi("SpellCap",   { "attr": s:curl, "ul": s:func })
call s:hi("SpellRare",  { "attr": s:curl, "ul": s:keyword })
call s:hi("SpellLocal", { "attr": s:curl, "ul": s:type })

