setlocal textwidth=80
setlocal formatoptions+=ta
setlocal spell
setlocal complete+=kspell
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
