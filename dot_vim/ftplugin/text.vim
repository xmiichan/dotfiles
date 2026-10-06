setlocal textwidth=80
setlocal formatoptions+=ta
setlocal spell
setlocal complete+=kspell

" break undo after punctuation
for ch in ['.', '!', '?', ',', ';', ':']
    execute 'inoremap <buffer> ' . ch . ' ' . ch . '<C-g>u'
endfor
