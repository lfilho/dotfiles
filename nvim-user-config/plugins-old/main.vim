if (!has('nvim'))
  " Make traditional vim aware of this folder so Plug can install itself in
  " there as well
  let &rtp = &rtp . ',  ~/.local/share/nvim/site/'
endif

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync
endif

call plug#begin('~/.local/share/nvim/site/plugged')

let pluginPath = '~/.config/nvim/plugins'

for fpath in split(globpath(pluginPath, '*.vim'), '\n')
  if (fpath != expand(pluginPath) . "/main.vim") " skip main.vim (this file)
    exe 'source' fpath
  endif
endfor

call plug#end()
