autocmd FileType c,cpp,css,java,javascript,perl,php,jade,matlab nmap <silent> <Leader>; <Plug>(cosco-commaOrSemiColon)
autocmd FileType c,cpp,css,java,javascript,perl,php,jade,matlab imap <silent> <Leader>; <c-o><Plug>(cosco-commaOrSemiColon)

let g:cosco_ignore_comment_lines = 1
