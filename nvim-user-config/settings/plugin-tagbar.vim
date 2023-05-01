nnoremap <silent> <leader>T :TagbarToggle<CR>

let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1
let g:tagbar_autopreview = 1
let g:tagbar_iconchars = ['▸', '▾']

let g:tagbar_type_markdown = {
    \ 'ctagstype' : 'markdown',
    \ 'kinds' : [
        \ 'h:headings',
        \ 'l:links',
        \ 'i:images'
    \ ],
    \ "sort" : 0
\ }
