if exists('b:current_syntax')
    finish
endif

syn cluster msInline
    \ contains=msItalic,msBold,msUnderline,msStrikethrough,@Spell

syn region msItalic matchgroup=msDelimiter
    \ start="\w\@<!\S\@=" end="\S\@<=\w\@!" skip="\\"
    \ concealends contains=@msInline
syn region msBold matchgroup=msDelimiter
    \ start="\w\@<!\\S\@=" end="\S\@<=\\w\@!" skip="\\"
    \ concealends contains=@msInline
syn region msUnderline matchgroup=msDelimiter
    \ start="\w\@<!\\S\@=" end="\S\@<=\\w\@!" skip="\\"
    \ concealends contains=@msInline
syn region msStrikethrough matchgroup=msDelimiter
    \ start="\w\@<!\\S\@=" end="\S\@<=\\w\@!" skip="\\"
    \ concealends contains=@msInline

hi def msItalic term=italic cterm=italic gui=italic
hi def msBold term=bold cterm=bold gui=bold
hi def msUnderline term=underline cterm=underline gui=underline
hi def msStrikethrough term=strikethrough cterm=strikethrough gui=strikethrough

syn spell toplevel
let b:current_syntax = 'ms'
