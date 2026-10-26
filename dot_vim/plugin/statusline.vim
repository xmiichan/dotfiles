" Statusline
function! StatuslineLsp() abort
    return exists('*lsp#get_allowed_servers')
        \ && !empty(lsp#get_allowed_servers()) ? '/LSP' : ''
endfunction

let &statusline = '%1*'
    \ . "%(%{&filetype!='help'?'  '.bufnr('%'):''} %)"
    \ . '%2* ‹‹ %t%r%w%m ›› %*  '
    \ . "%{FugitiveStatusline()}"
    \ . "%{ObsessionStatus()}"
    \ . '%=%{toupper(&ft)}%*'
    \ . "%{&spell?'/SPELL':''}"
    \ . '%{StatuslineLsp()}'
    \ . "%{&l:fo=~#'a'?'/AUTOFMT':''}"
    \ . '  %3* ‹‹ %2l:%02v :: %2P ›› '
