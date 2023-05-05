Plug 'mattn/webapi-vim' " web api for vim. Required by some plugins
Plug 'mbbill/undotree' " visualize your Vim undo tree
Plug 'szw/vim-maximizer' "Maximizes and restores the current window
Plug 'tommcdo/vim-exchange' " Easy text exchange operator
Plug 'tomtom/tlib_vim' " Utility functions used by some plugins
Plug 'tpope/vim-abolish' " search for, substitute, and abbreviate multiple variants of a word
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-endwise' " wisely add `end` in ruby, endfunction/endif/more in vim script, etc
Plug 'tpope/vim-ragtag' " mappings for HTML, XML, PHP, ASP, eRuby, JSP, etc
Plug 'tpope/vim-repeat' " enable repeating supported plugin maps with `.`
Plug 'tpope/vim-surround' " quoting/parenthesizing made simple
Plug 'tpope/vim-unimpaired' " does too much to describe here :). Check the full description at its github page
Plug 'vim-scripts/AnsiEsc.vim' " ansi escape sequences concealed. Used by some plugins. I think.
Plug 'vim-scripts/YankRing.vim' " Maintains and handles a history of previous yanks, changes and deletes
Plug 'vim-scripts/camelcasemotion' " Motion through CamelCaseWords and underscore_notation
Plug 'vim-scripts/lastpos.vim' " Passive. Last position jump improved.
Plug 'vim-scripts/matchit.zip' "extended % matching for HTML, LaTeX, and many other languages
if system('uname')=~'Darwin'
    Plug 'zerowidth/vim-copy-as-rtf' " Does what it says. Useful for copying colored code ready to be pasted on slides, for example.
endif
