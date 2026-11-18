if exists('b:current_syntax')
    finish
endif

syn cluster manuscriptInline
    \ contains=manuscriptItalic,manuscriptBold,@Spell

syn region manuscriptItalic matchgroup=manuscriptDelimiter
    \ start="\w\@<!_\S\@=" end="\S\@<=_\w\@!" skip="\\_"
    \ concealends contains=@manuscriptInline
syn region manuscriptBold matchgroup=manuscriptDelimiter
    \ start="\w\@<!\*\S\@=" end="\S\@<=\*\w\@!" skip="\\\*"
    \ concealends contains=@manuscriptInline

hi def manuscriptItalic term=italic cterm=italic gui=italic
hi def manuscriptBold term=bold cterm=bold gui=bold

syn spell toplevel
let b:current_syntax = 'manuscript'
