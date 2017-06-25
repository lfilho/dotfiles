let g:rg_highlight = 1

"Use RipGrep for lightning fast Gsearch command
set grepprg=rg\ --vimgrep\ --no-heading
set grepformat=%f:%l:%c:%m,%f:%l:%m
let g:grep_cmd_opts = '--line-number'

" See vim-quickfix.vim and vim-search.vim files for more usages of Rg
