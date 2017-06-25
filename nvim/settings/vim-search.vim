function! GetVisual()
  let reg_save = getreg('"')
  let regtype_save = getregtype('"')
  let cb_save = &clipboard
  set clipboard&
  normal! ""gvy
  let selection = getreg('"')
  call setreg('"', reg_save, regtype_save)
  let &clipboard = cb_save
  return selection
endfunction

"grep the current word using
"Mnemonic: *K*urrent
nnoremap <silent> K :Rg <cword><CR>

"grep the current visual selection
"Mnemonic: *K*urrent
vnoremap K :<C-U>execute 'Rg "' . GetVisual() . '"'<CR>

" File search mappings:
" open up a ripgrep line, with a quote started for the search
"
" Mnemonic: *f*ind in *a*ll files. Or *F*ind *A*nywhere.
nnoremap <leader>fa :Rg --smart-case ""<left>
" Mnemonic: *f*ind *f*iles.
nnoremap <leader>ff :Rg --smart-case --files ""<Left>
" Mnemonic: *f*ind usages of *t*his file
nnoremap <leader>ft :exec "Rg " . expand("%:t:r")<CR>

set wrapscan        " Search wrap the file
set showmatch

" Using Perl/Python regex style by default when searching
nnoremap / /\v
vnoremap / /\v

" Keep search matches in the middle of the window.
let g:indexed_search_center = 1

" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz
nnoremap <c-o> <c-o>zz
