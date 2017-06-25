" use ,F to jump to tag in a vertical split
" Mnemonic: *F*ind the current tag under the cursor
nnoremap <silent> <leader>F :let word=expand("<cword>")<CR>:vsp<CR>:wincmd w<cr>:exec("tag ". word)<cr>
