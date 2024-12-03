- close window/split with a keymap (before it was Q, space-c closes the buffer only, keeping the split)
  - Maybe disable https://github.com/famiu/bufdelete.nvim ?
- how to use the debugger https://github.com/mfussenegger/nvim-dap

Check community versions for the bellow:
https://github.com/nvim-pack/nvim-spectre
https://github.com/folke/trouble.nvim
https://git.sr.ht/~whynothugo/lsp_lines.nvim
https://github.com/Exafunction/codeium.vim
https://github.com/uga-rosa/ccc.nvim

is tpope/vim-repeat needed?
:TOhtml is not working. Lazy hijacking it?

--- https://github.com/Wansmer/sibling-swap.nvim
--- https://github.com/Wansmer/binary-swap.nvim

https://github.com/vuki656/package-info.nvim
https://github.com/abecodes/tabout.nvim -- ver se nao conflita com algo
https://github.com/drybalka/tree-climber.nvim
https://github.com/ethanholz/nvim-lastplace

rethink the mnemonics. like maybe "<leader>n" for any Navigation plugins

remove fugitive? maybe neogit or lazygit?

normalize keymaps for opening splits across neotree, telescope...

command DiffOrig vert new | set buftype=nofile | read ++edit # | 0d\_
\ | diffthis | wincmd p | diffthis

Use ":DiffOrig" to see the differences between the current buffer and the file it was loaded from.

# TMUX

- How to kickstart it? do i need to put it as a login shell or what?
- will current .conf work with neovim? check smart-splits compared to vim tmux navigator for compat with neovim too
- see if reattach to user space brew package is still needed
- Config seems borked. seek another one on the web
- install catpuccing
