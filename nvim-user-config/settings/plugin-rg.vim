"Use RipGrep for lightning fast Gsearch command
set grepprg=rg\ --vimgrep\ --smart-case\ --follow
set grepformat=%f:%l:%c:%m,%f:%l:%m
let g:grep_cmd_opts = '--line-number'
