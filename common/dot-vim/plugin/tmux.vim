" tmux integration
let s:no_float = "if -F '#{!:#{pane_floating_flag}}' "

function! s:Tmux(args) abort
    if !empty($TMUX)
        call system('tmux ' . a:args)
    endif
endfunction

" move focus to other window or hand over to tmux
function! s:Move(dir, tmux_flag) abort
    if winnr(a:dir) == winnr()
        call s:Tmux('select-pane -Z ' . a:tmux_flag)
    else
        execute 'wincmd' a:dir
    endif
endfunction

" resize window or hand over to tmux
function! s:Resize(dir, tmux_flag) abort
    let l:horizontal = a:dir ==# 'h' || a:dir ==# 'l'
    let l:resize = l:horizontal ? 'vertical resize ' : 'resize '
    " horizontal = 5 chars, vertical = 1 line
    let l:step = l:horizontal ? 5 : 1
    " determine which direction to resize in, forward or backward
    let l:forward = l:horizontal ? 'l' : 'j'
    let l:backward = l:horizontal ? 'h' : 'k'
    " if forward, we grow the window, otherwise we shrink it
    let l:grow = a:dir ==# l:forward
    if winnr(l:forward) != winnr()
        execute l:resize . (l:grow ? '+' : '-') . l:step
    elseif winnr(l:backward) != winnr()
        execute l:resize . (l:grow ? '-' : '+') . l:step
    else
        call s:Tmux(s:no_float . "'resize-pane " . a:tmux_flag . " 5'")
    endif
endfunction

" swap two windows or hand over to tmux
function! s:Swap(dir, tmux_pane) abort
    let l:target = winnr(a:dir)
    if l:target == winnr()
        call s:Tmux(s:no_float . "'swap-pane -s \"" . a:tmux_pane . "\"'")
        return
    endif
    let l:buf = bufnr('%')
    let l:view = winsaveview()
    execute 'buffer' winbufnr(l:target)
    execute l:target . 'wincmd w'
    execute 'buffer' l:buf
    call winrestview(l:view)
endfunction

" we gotta recognize esc x as M-x. terminal sends two byes, we map it into
" one keycode. idea stolen from tpope's vim-rsi.
execute "set <M-h>=\<Esc>h"
execute "set <M-j>=\<Esc>j"
execute "set <M-k>=\<Esc>k"
execute "set <M-l>=\<Esc>l"
execute "set <M-H>=\<Esc>H"
execute "set <M-J>=\<Esc>J"
execute "set <M-K>=\<Esc>K"
execute "set <M-L>=\<Esc>L"
" for C-M-x we gotta cheat even more so we don't error on the fact that C-j
" is newline etc. _FF..t_FI are <F25> through <F28>
let &t_FF = "\e\<C-h>"
let &t_FG = "\e\<C-j>"
let &t_FH = "\e\<C-k>"
let &t_FI = "\e\<C-l>"

nnoremap <silent> <M-h> :call <SID>Move('h', '-L')<cr>
nnoremap <silent> <M-j> :call <SID>Move('j', '-D')<cr>
nnoremap <silent> <M-k> :call <SID>Move('k', '-U')<cr>
nnoremap <silent> <M-l> :call <SID>Move('l', '-R')<cr>

nnoremap <silent> <M-H> :call <SID>Resize('h', '-L')<cr>
nnoremap <silent> <M-J> :call <SID>Resize('j', '-D')<cr>
nnoremap <silent> <M-K> :call <SID>Resize('k', '-U')<cr>
nnoremap <silent> <M-L> :call <SID>Resize('l', '-R')<cr>

nnoremap <silent> <F25> :call <SID>Swap('h', '{left-of}')<cr>
nnoremap <silent> <F26> :call <SID>Swap('j', '{down-of}')<cr>
nnoremap <silent> <F27> :call <SID>Swap('k', '{up-of}')<cr>
nnoremap <silent> <F28> :call <SID>Swap('l', '{right-of}')<cr>

if has('terminal')
    tnoremap <silent> <M-h> <C-w>:call <SID>Move('h', '-L')<cr>
    tnoremap <silent> <M-j> <C-w>:call <SID>Move('j', '-D')<cr>
    tnoremap <silent> <M-k> <C-w>:call <SID>Move('k', '-U')<cr>
    tnoremap <silent> <M-l> <C-w>:call <SID>Move('l', '-R')<cr>

    tnoremap <silent> <M-H> <C-w>:call <SID>Resize('h', '-L')<cr>
    tnoremap <silent> <M-J> <C-w>:call <SID>Resize('j', '-D')<cr>
    tnoremap <silent> <M-K> <C-w>:call <SID>Resize('k', '-U')<cr>
    tnoremap <silent> <M-L> <C-w>:call <SID>Resize('l', '-R')<cr>

    tnoremap <silent> <F25> <C-w>:call <SID>Swap('h', '{left-of}')<cr>
    tnoremap <silent> <F26> <C-w>:call <SID>Swap('j', '{down-of}')<cr>
    tnoremap <silent> <F27> <C-w>:call <SID>Swap('k', '{up-of}')<cr>
    tnoremap <silent> <F28> <C-w>:call <SID>Swap('l', '{right-of}')<cr>
endif
