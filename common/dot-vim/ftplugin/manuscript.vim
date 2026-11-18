setlocal textwidth=72
setlocal formatoptions=tqaw2
setlocal noautoindent nosmartindent
setlocal expandtab
setlocal spell
setlocal complete+=kspell
if exists('+autocomplete')
    setlocal noautocomplete
endif
let b:asyncomplete_enable = 0

setlocal conceallevel=2
setlocal concealcursor=nvic

nnoremap <buffer><silent> <leader>c :center<cr>
nnoremap <buffer><silent> <leader>< :left<cr>
nnoremap <buffer><silent> <leader>> :right<cr>

" break undo after punctuation
for ch in ['.', '!', '?', ',', ';', ':']
    execute 'inoremap <buffer> ' . ch . ' ' . ch . '<C-g>u'
endfor

command! -buffer -range Center <line1>,<line2>center

" yank without linebreaks to system clipboard/unnamed reg
function! s:YankJoined() abort
    let l:text = ''
    for l:line in v:event.regcontents
        let l:text .= trim(l:line) . (l:line =~# ' $' ? ' ' : "\n")
    endfor
    let l:text = trim(l:text, " \n", 2)
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

" justify for vim 9+ like in wordstar
if !has('textprop') || !has('patch-9.0.0067')
    finish
endif

let s:prop = 'manuscript_pad'

if empty(prop_type_get(s:prop, {'bufnr': bufnr()}))
    call prop_type_add(s:prop, {'bufnr': bufnr()})
endif

function! s:ConcealedCount(lnum, len) abort
    if &conceallevel == 0
        return 0
    endif
    let l:count = 0
    for l:col in range(1, a:len)
        if synconcealed(a:lnum, l:col)[0]
            let l:count += 1
        endif
    endfor
    return l:count
endfunction

function! s:JustifyLine(lnum) abort
    let l:line = getline(a:lnum)
    if l:line !~# '\S\s* $'
        return
    endif
    let l:text = substitute(l:line, '\s\+$', '', '')
    let l:pad = &textwidth - strdisplaywidth(l:text)
        \ + s:ConcealedCount(a:lnum, strlen(l:text))
    let l:cols = []
    let l:start = matchend(l:text, '^ *')
    while 1
        let l:end = matchend(l:text, '\S\zs \+\ze\S', l:start)
        if l:end < 0
            break
        endif
        call add(l:cols, l:end + 1)
        let l:start = l:end
    endwhile
    if empty(l:cols) || l:pad <= 0
        return
    endif
    let l:extra = repeat([0], len(l:cols))
    for l:i in range(l:pad)
        let l:extra[-1 - l:i % len(l:cols)] += 1
    endfor
    for l:i in filter(range(len(l:cols)), {_, i -> l:extra[i] > 0})
        call prop_add(a:lnum, l:cols[l:i],
            \ {'type': s:prop, 'text': repeat(' ', l:extra[l:i])})
    endfor
endfunction

function! s:Render(first, last) abort
    call prop_remove({'type': s:prop, 'all': 1}, a:first, a:last)
    for l:lnum in range(a:first, a:last)
        call s:JustifyLine(l:lnum)
    endfor
endfunction

function! s:Refresh() abort
    let l:view = [line('w0'), line('w$'), b:changedtick, &textwidth]
    if get(w:, 'manuscript_view', []) ==# l:view
        return
    endif
    let w:manuscript_view = l:view
    call s:Render(l:view[0], l:view[1])
endfunction

function! s:FormatExpr() abort
    let l:last = v:lnum + max([v:count, 1]) - 1
    if !empty(prop_list(v:lnum,
        \ {'end_lnum': l:last, 'types': [s:prop]}))
        call prop_remove({'type': s:prop, 'all': 1}, v:lnum, l:last)
        unlet! w:manuscript_view
    endif
    return 1
endfunction

setlocal formatexpr=s:FormatExpr()

augroup manuscript_justify
    autocmd! * <buffer>
    autocmd BufWinEnter,CursorMoved,TextChanged,InsertLeave <buffer>
        \ call s:Refresh()
augroup END
