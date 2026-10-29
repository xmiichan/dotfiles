setlocal textwidth=80
setlocal formatoptions+=ta
setlocal spell
setlocal complete+=kspell
setlocal conceallevel=2
if exists('+autocomplete')
    setlocal noautocomplete
endif

" break undo after punctuation
for ch in ['.', '!', '?', ',', ';', ':']
    execute 'inoremap <buffer> ' . ch . ' ' . ch . '<C-g>u'
endfor

" yank without linebreaks to system clipboard/unnamed reg
function! s:YankJoined() abort
    let l:text = join(map(copy(v:event.regcontents), 'trim(v:val)'), "\n")
    let l:text = substitute(l:text, '\n\@<!\n\n\@!', ' ', 'g')
    call setreg('"', l:text, 'v')
    call setreg('+', l:text, 'v')
endfunction

augroup yank_joined_buf
    autocmd! * <buffer>
    autocmd TextYankPost <buffer>
        \ if v:event.operator ==# 'y' && v:event.regname ==# '+'
        \ | call s:YankJoined()
        \ | endif
augroup END

" don't autowrap code blocks
function! s:InCodeBlock() abort
    for l:id in synstack(line('.'), col('.'))
        if synIDattr(l:id, 'name') =~# '\v^(markdownCode|markdownCodeBlock|mkdCode|mkdSnippet)'
            return 1
        endif
    endfor
    return 0
endfunction

function! s:ToggleWrap() abort
    if s:InCodeBlock()
        setlocal formatoptions-=t formatoptions-=a
    else
        setlocal formatoptions+=t formatoptions+=a
    endif
endfunction

augroup markdown_code_nowrap
    autocmd! * <buffer>
    autocmd CursorMoved,CursorMovedI <buffer> call s:ToggleWrap()
augroup END
