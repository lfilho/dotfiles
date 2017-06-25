augroup markdown
    au!
    let g:markdown_fenced_languages = ['java', 'coffee', 'css', 'erb=eruby', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'sass', 'xml', 'html']

    " Assumes you have `vmd` installed on your system
    command! MarkdownPreview :!vmd %
augroup END

" This function/command will surround keymappings with the <kbd> tag, so it
" can look nicer on github (or any markdown viewer)
" Examples:
"      Ctrl-b     will become                              <kbd>Ctrl</kbd>-<kbd>b</kbd>
"     `Ctrl-x`    (surrounded by backticks) will become    <kbd>Ctrl</kbd>-<kbd>x</kbd>
function! SelectionToKbdTags() range
  s#\%V`\?\(Space\|Spacebar\|Shift\|Esc\|Alt\|Cmd\|Ctrl\|[^-]\)`\?#<kbd>\1</kbd>#gi
endfunction
command! -range SelectionToKbdTags call SelectionToKbdTags()
