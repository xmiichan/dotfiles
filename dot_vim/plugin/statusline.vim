" Statusline
function! StatuslineLsp() abort
    return exists('*lsp#get_allowed_servers')
        \ && !empty(lsp#get_allowed_servers()) ? '/LSP' : ''
endfunction

let &statusline = '%1*'
    \ . "%(%{&filetype!='help'?'  '.bufnr('%'):''} %)"
    \ . '%* ‹‹ %t%r%w%m%* ›› '
    \ . "%{FugitiveStatusline()}"
    \ . '%=%{toupper(&ft)}%*'
    \ . "%{&spell?'/SPELL':''}"
    \ . '%{StatuslineLsp()}'
    \ . '  %1* ‹‹ %2l:%02v :: %2P ›› '
