" via: http://rails-bestpractices.com/posts/60-remove-trailing-whitespace
" Strip trailing whitespace
function! <SID>StripTrailingWhitespaces()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction
command! StripTrailingWhitespaces call <SID>StripTrailingWhitespaces()

autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" Delete blank lines after a { or before a }
function! <SID>StripBlockPadding()
    %s/^\s*\n\ze\s*}//ge
    %s/{\n\s*\ze\n/{/ge
endfunction

command! StripBlockPadding call <SID>StripBlockPadding()
