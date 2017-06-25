if exists("g:ctrlp_user_command")
  unlet g:ctrlp_user_command
endif
if executable('rg')
  " Use rg in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'rg --files --smart-case %s'

  " rg is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
else
  " Fall back to using git ls-files if Rg is not available
  let g:ctrlp_custom_ignore = '\.git$\|\.hg$\|\.svn$'
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others']
endif

" Default to filename searches
let g:ctrlp_by_filename = 1

" Don't jump to already open window. This is annoying if you are maintaining
" several Tab workspaces and want to open two windows into the same file.
let g:ctrlp_switch_buffer = 0

" We don't want to use Ctrl-p as the mapping because
" it interferes with YankRing (paste, then hit ctrl-p)
let g:ctrlp_map = '<leader>t'
nnoremap <silent> <leader>t :CtrlP<CR>

" Additional mapping for buffer search
nnoremap <silent> <leader>b :CtrlPBuffer<cr>

" Idea from : http://www.charlietanksley.net/blog/blog/2011/10/18/vim-navigation-with-lustyexplorer-and-lustyjuggler/
" Open CtrlP starting from a particular path, making it much
" more likely to find the correct thing first. mnemonic 'jump to [something]'
" map <leader>ja :CtrlP app/assets<CR>
" map <leader>jm :CtrlP app/models<CR>
" map <leader>jc :CtrlP app/controllers<CR>
" map <leader>jv :CtrlP app/views<CR>
" map <leader>jh :CtrlP app/helpers<CR>
" map <leader>jl :CtrlP lib<CR>
" map <leader>jp :CtrlP public<CR>
" map <leader>js :CtrlP spec<CR>
" map <leader>jf :CtrlP fast_spec<CR>
" map <leader>jd :CtrlP db<CR>
" map <leader>jC :CtrlP config<CR>
" map <leader>jV :CtrlP vendor<CR>
" map <leader>jF :CtrlP factories<CR>
" map <leader>jT :CtrlP test<CR>

" Mnemonic: *M*ethod - jump to a method (tag in current file)
" Ctrl-m is not good - it overrides behavior of Enter
nnoremap <silent> <leader>M :CtrlPBufTag<CR>
