**For the original README, see [here](./README.md)**

# Install (for Linux Users)

1. Make sure you have `zsh` installed on your machine (default location is `/bin/zsh`). Type `zsh --version` to see if you have it. If not, install it running the command `sudo apt-get install zsh`
2. Make sure you have `vim` installed. If not, install it with `sudo apt-get install vim`
3. Run the installation script running ```sh -c "`curl -fsSL https://raw.githubusercontent.com/lfilho/dotfiles/master/install.sh`"```
4. If asked, provide your superuser password
5. Configure your terminal program to point the command to zsh (default `/bin/zsh`)
6. Restart you Terminal
7. You're done.

# Install (for OSX Users)

    sh -c "`curl -fsSL https://raw.githubusercontent.com/lfilho/dotfiles/master/install.sh`"

See the differences from this repo in the section below, and the original README right after it:

The keymaps for each plugin or behaviour can be found peeking at [doc](doc) folder.

# This fork's differences

* ZSH
  * New aliases:
    * `v` alias for opening `mvim` (MacVim)
    * Docker aliases
  * My personal zsh prompt theme (lfilho)
  * [ZSH AutoSuggestions](https://github.com/zsh-users/zsh-autosuggestions) with <kbd>ctrl</kbd> + <kbd>N</kbd> for accept suggestions

* GIT
  * New aliases
    * `ren-remote`. Rename remote branch
    * `ren-local`  Rename local branch
    * `ren`. Rename local and remote branch
    * `amend-noedit`. Amend commit reusing last commit message
    * Use `diff-so-fancy` by default to show better diffs

* iTerm2
  * My own theme (`base16-lfilho.dark.256`)

* VIM
  * [Javascript dict](https://raw.githubusercontent.com/cooldaemon/myhome/master/.vim/dict/javascript.dict) + NeoComplete hook
  * [Cosco.vim](http://github.com/lfilho/cosco.vim). my own plugin for comma or semi-colon easy insertion
  * [Sideways.vim](https://github.com/AndrewRadev/sideways.vim). Makes dealing with method arguments easier
  * [Local .vimrc](https://github.com/MarcWeber/vim-addon-local-vimrc). Loads/runs a `.vimrc` relative to the current folder (great for project specific configurations)
  * [base16-lfilho](https://github.com/lfilho/base16-vim). My personal colorscheme for vim
  * [Editor Config](https://github.com/editorconfig/editorconfig-vim) plugin
  * [Expand region](https://github.com/terryma/vim-expand-region). Hit `<enter>` to expand selection inside stuff like `(), [], {}, <>,` etc
  * [Sparkup](https://github.com/rstacruz/sparkup). HTML Zen Coding.
  * OSX only: [Copy-as-RTF](https://github.com/zerowidth/vim-copy-as-rtf). For copying syntax highlighted code to the clipboard and pasting, for example on Keynote, Pages, etc
  * Beautiful Fantasque font
  * Splits open to the right (not left) and VSplits open to the bottom (not top)
  * Strips trailing withespace automatically upon save
  * Perl regex style by default
  * Markdown files are able to show fanced languages (programming blocks with syntax highlighting)
  * Custom lightline bar
  * NERDTree ignores `node_modules` folder
  * Vim Function to style RequireJS imports (`:StyleRequireJsImports`)
  * Vim Function to remove padding blank lines inside functions (`:KillBlockPadding`)
  * Return `<C-x>` and `<C-z>` to their original functions
    * `,,n` and `,,p` to navigate the quickfix error list
  * `Ag` now highlights the search and doesn't open first result by default

* OSX
  * Config to open MacVim maximized by default
  * New brew packages
    * `diff-so-fancy`
    * `tidy5-html5`
