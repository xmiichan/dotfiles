if exists('b:current_syntax')
    finish
endif

syn cluster msInline
    \ contains=msItalic,msBold,msUnderline,msStrikethrough,@Spell

" ^Y italic
syn region msItalic matchgroup=msDelimiter
    \ start="\%x19" end="\%x19"
    \ concealends contains=@msInline
" ^B bold
syn region msBold matchgroup=msDelimiter
    \ start="\%x02" end="\%x02"
    \ concealends contains=@msInline
" ^U underline
syn region msUnderline matchgroup=msDelimiter
    \ start="\%x15" end="\%x15"
    \ concealends contains=@msInline
" ^X strikethrough
syn region msStrikethrough matchgroup=msDelimiter
    \ start="\%x18" end="\%x18"
    \ concealends contains=@msInline

function! s:Highlight() abort
    hi def msItalic term=italic cterm=italic gui=italic
    hi def msBold term=bold cterm=bold gui=bold
    hi def msUnderline term=underline cterm=underline gui=underline
    hi def msStrikethrough term=strikethrough cterm=strikethrough
        \ gui=strikethrough
endfunction

call s:Highlight()

augroup manuscript_highlight
    autocmd!
    autocmd ColorScheme * call s:Highlight()
augroup END

syn spell toplevel
let b:current_syntax = 'manuscript'
