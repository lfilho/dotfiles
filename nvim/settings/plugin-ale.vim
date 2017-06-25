let g:ale_fixers = {'javascript': ['eslint']}
let g:ale_fix_on_save = 1

nmap <silent> ,,p <Plug>(ale_previous_wrap)
nmap <silent> ,,n <Plug>(ale_next_wrap)
