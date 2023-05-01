" Make nerdtree look nice
let NERDTreeMinimalUI = 1

" Ignore Node.js `node_modules` folder
let NERDTreeIgnore=['^node_modules$[[dir]]']

" Open the project tree and expose current file in the nerdtree
" calls NERDTreeFind if NERDTree is active, current window contains a modifiable file, and we're not in vimdiff
function! OpenNerdTree()
  if &modifiable && strlen(expand('%')) > 0 && !&diff
    NERDTreeFind
  else
    NERDTreeToggle
  endif
endfunction

" Mnemonic: *p*roject
" Open or close a NERDTree window:
nnoremap <leader>p :NERDTreeToggle<CR>
" Open or close a NERDTree window in the current file node:
nnoremap <leader>P :call OpenNerdTree()<CR>

" When using DevIcons, we want to remove the pre padding.
" If we stop using DevIcons, make the following a single space.
let g:WebDevIconsNerdTreeBeforeGlyphPadding = ''
