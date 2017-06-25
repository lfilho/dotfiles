" These keys are easier to type than the default set
" We exclude semicolon because it's hard to read and
" i and l are too easy to mistake for each other slowing
" down recognition. The home keys and the immediate keys
" accessible by middle fingers are available
let g:EasyMotion_keys='asdfjkloweiopqrnv'
let g:EasyMotion_smartcase = 1 "With this, v will match both v and V, but V will match V only
let g:EasyMotion_use_smartsign_us = 1 " Same as above, but for symbols and numerals. 1 will match 1 and !; ! matches ! only
nmap <leader><ESC> <Plug>(easymotion-bd-w)
nmap <leader><S-ESC> <Plug>(easymotion-bd-b)
