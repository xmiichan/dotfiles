" replace operator (cr to replace without yanking)
function! s:Replace(type, ...) abort
    let l:sel_save = &selection
    let &selection = 'inclusive'
    let l:reg = getreg('"', 1, 1)
    let l:regtype = getregtype('"')
    if a:0
        silent normal! gvp
    elseif a:type == 'line'
        silent normal! '[V']p
    else
        silent normal! `[v`]p
    endif
    call setreg('"', l:reg, l:regtype)
    let &selection = l:sel_save
endfunction

nmap <silent> cr :set opfunc=<SID>Replace<cr>g@
nmap <silent> crr :set opfunc=<SID>Replace<cr>g@_
nmap <silent> cR cr$
xmap <silent> cr :<C-u>call <SID>Replace(visualmode(), 1)<cr>
