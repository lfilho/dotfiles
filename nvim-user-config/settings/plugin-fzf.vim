" MAPPINGS:
" Mnemonic: *F*ind *F*iles (file name)
nnoremap <leader>ff :Files<CR>
" Mnemonic: *F*ind *B*uffers
nnoremap <leader>fb :Buffers<CR>
" Mnemonic: *F*ind by *G*reping (file contents)
nnoremap <leader>fg :Rg<CR>
" Mnemonic: *F*ind usages of *T*his file
nnoremap <leader>ft :<C-U>exec "Rg ". expand("%:t:r")<CR>

"Mnemonic: `j` is like clicking a link (down).
vnoremap <leader>j :<C-U>exec "Rg ". GetVisual()<CR>
nmap <leader>j :exec "Rg ".expand('<cword>')<CR>

" The below is necessary so :Rg won´t consider file names for grepping,
" only file contents:
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
