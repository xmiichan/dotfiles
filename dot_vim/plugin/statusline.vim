" Statusline
function! s:Vcs() abort
    let l:cd = 'cd ' . shellescape(expand('%:p:h')) . ' 2>/dev/null && '
    let l:out = system(l:cd . 'jj log --no-graph -T bookmarks' . " -r 'heads(::@ & bookmarks())' 2>/dev/null")
    if !v:shell_error
        return ' ~' . trim(l:out) . ' ' .trim(system(l:cd . "jj log --no-graph -r @ -T 'change_id.shortest()'"))
    endif
    let l:out = system(l:cd . 'git rev-parse --abbrev-ref HEAD 2>/dev/null')
    return v:shell_error ? '' : ' @' . trim(l:out)
endfunction

augroup statusline_vcs
    autocmd!
    autocmd BufReadPost,BufNewFile,BufWritePost,FocusGained *
        \ let b:vcs = s:Vcs()
augroup END

function! StatuslineLsp() abort
    return exists('*lsp#get_allowed_servers')
        \ && !empty(lsp#get_allowed_servers()) ? '/LSP' : ''
endfunction

let &statusline = '%1*'
    \ . "%(%{&filetype!='help'?'  '.bufnr('%'):''} %)"
    \ . '%* ‹‹ %t%r%w%m%* ›› '
    \ . "%{get(b:,'vcs','')}"
    \ . '%=%{toupper(&ft)}%*'
    \ . "%{&spell?'/SPELL':''}"
    \ . '%{StatuslineLsp()}'
    \ . '  %1* ‹‹ %2l:%02v :: %2P ›› '
