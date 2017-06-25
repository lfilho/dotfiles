" ========================================
" General vim sanity improvements
" ========================================
"

"make Y consistent with C and D
nnoremap Y y$
function! YRRunAfterMaps()
  nnoremap Y   :<C-U>YRYankCount 'y$'<CR>
endfunction

" Make 0 go to the first character rather than the beginning
" of the line. When we're programming, we're almost always
" interested in working with text rather than empty space. If
" you want the traditional beginning of line, use ^
nnoremap 0 ^
nnoremap ^ 0

" gary bernhardt's hashrocket
imap <c-l> <space>=><space>

"Go to last edit location with ,.
nnoremap <leader>. '.
"When typing a string, your quotes auto complete. Move past the quote
"while still in insert mode by hitting Ctrl-a. Example:
"
" type 'foo<c-a>
"
" the first quote will autoclose so you'll get 'foo' and hitting <c-a> will
" put the cursor right after the quote
imap <C-a> <esc>wa

" ============================
" Shortcuts for everyday tasks
" ============================

" copy current filename into system clipboard
" this is helpful to paste someone the path you're looking at
" Mnemonic: (c)urrent (f)ull filename (Eg.: ~/.yadr/nvim/settings/vim-keymaps.vim)
nnoremap <silent> <leader>cf :let @* = expand("%:~")<CR>
" Mnemonic: (c)urrent (r)elative filename (Eg.: nvim/settings/vim-keymaps.vim)
nnoremap <silent> <leader>cr :let @* = expand("%")<CR>
" Mnemonic: (c)urrent (n)ame of the file (Eg.: vim-keymaps.vim)
nnoremap <silent> <leader>cn :let @* = expand("%:t")<CR>

"(v)im (c)ommand - execute current line as a vim command
nmap <silent> <leader>vc yy:<C-f>p<C-c><CR>

"(v)im (r)eload
nmap <silent> <leader>vr :so %<CR>

" Type ,hl to toggle highlighting on/off, and show current value.
noremap <leader>hl :set hlsearch! hlsearch?<CR>

" These are very similar keys. Typing 'a will jump to the line in the current
" file marked with `ma`. However, `a will jump to the line and column marked
" with ma.  It’s more useful in any case I can imagine, but it’s located way
" off in the corner of the keyboard. The best way to handle this is just to
" swap them: http://items.sjbach.com/319/configuring-vim-right
nnoremap ' `
nnoremap ` '

" Get the current highlight group. Useful for then remapping the color
map <leader>hi :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">" . " FG:" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"fg#")<CR>

" ,hp = html preview
if has('macos')
  map <silent> <leader>hp :!open -a Safari %<CR><CR>
endif
