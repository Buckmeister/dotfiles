if empty(glob("~/.config/nvim/coc-settings.json"))
  call system("ln -s ~/.vim/coc-settings.json ~/.config/nvim/")
endif
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
