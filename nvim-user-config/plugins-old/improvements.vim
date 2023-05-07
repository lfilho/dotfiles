Plug 'tpope/vim-ragtag' " mappings for HTML, XML, PHP, ASP, eRuby, JSP, etc
Plug 'tpope/vim-repeat' " enable repeating supported plugin maps with `.`
Plug 'tpope/vim-surround' " quoting/parenthesizing made simple
Plug 'tpope/vim-unimpaired' " does too much to describe here :). Check the full description at its github page
Plug 'vim-scripts/YankRing.vim' " Maintains and handles a history of previous yanks, changes and deletes
Plug 'vim-scripts/camelcasemotion' " Motion through CamelCaseWords and underscore_notation
Plug 'vim-scripts/matchit.zip' "extended % matching for HTML, LaTeX, and many other languages
if system('uname')=~'Darwin'
    Plug 'zerowidth/vim-copy-as-rtf' " Does what it says. Useful for copying colored code ready to be pasted on slides, for example.
endif
