" " http://vimcasts.org/episodes/soft-wrapping-text/
function! SetupWrapping()
  setlocal wrap linebreak nolist
  setlocal showbreak=…
endfunction

augroup AutoWrapFiles
    autocmd!
    autocmd FileType {tex,markdown,text} call SetupWrapping()
augroup END

command! -nargs=* Wrap call SetupWrapping()
