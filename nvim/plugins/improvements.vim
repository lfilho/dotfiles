Plug 'AndrewRadev/sideways.vim' " move function arguments (and other delimited-by-something items) left and right
Plug 'AndrewRadev/splitjoin.vim' " splits or joins lines more smartly
Plug 'Keithbsmiley/investigate.vim' " for looking up documentation
Plug 'MarcWeber/vim-addon-local-vimrc' " local (per project) vim configs
Plug 'MarcWeber/vim-addon-mw-utils' " Vim Script Addons that some plugins depend on
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } " Async auto complete
Plug 'bogado/file-line' " Enables opening a file in a given line
Plug 'christoomey/vim-tmux-navigator' " Seamless navigation between vim and tmux windows
Plug 'craigemery/vim-autotag' " Automatically discover and update ctags files on save
Plug 'editorconfig/editorconfig-vim' " per project code style configs (tabs, spaces, line breaks, etc)
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
