Plug 'AndrewRadev/sideways.vim' " move function arguments (and other delimited-by-something items) left and right
Plug 'MarcWeber/vim-addon-local-vimrc' " local (per project) vim configs
Plug 'bogado/file-line' " Enables opening a file in a given line
Plug 'christoomey/vim-tmux-navigator' " Seamless navigation between vim and tmux windows
Plug 'godlygeek/tabular' " Commands for easily aligning tabular data
Plug 'goldfeld/ctrlr.vim' "Ex command history reverse-i-search for Vim
" Plug 'jby/tmux.vim' " Syntax for tmux files
Plug 'jiangmiao/auto-pairs' " insert or delete brackets, parens, quotes in pair
Plug 'lfilho/cosco.vim' "VIM colon and semicolon insertion bliss Edit
" Plug 'majutsushi/tagbar' " displays tags in a window, ordered by scope
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
