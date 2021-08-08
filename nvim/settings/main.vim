let settingsPath = '~/.config/nvim/settings'
let expandedSettingsPath = expand(settingsPath)
let uname = system("uname -s")

for fpath in split(globpath(settingsPath, '*.vim'), '\n')
  if (fpath != expandedSettingsPath . "/main.vim") " skip main.vim (this file)
    if (fpath == expandedSettingsPath . "/vim-keymaps-mac.vim") && uname[:4] ==? "linux"
      continue " skip mac mappings for linux
    endif

    if (fpath == expandedSettingsPath . "/vim-keymaps-linux.vim") && uname[:4] !=? "linux"
      continue " skip linux mappings for mac
    endif

    exe 'source' fpath
  end
endfor

