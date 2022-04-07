if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let b:undo_ftplugin =
      \ 'setlocal
      \ modifiable<
      \ swapfile<
      \ expandtab<
      \ list<
      \ readonly<
      \ textwidth<
      \ number<
      \ relativenumber<
      \ readonly<
      \ scrolloff<
      \ shiftwidth<
      \ signcolumn<
      \ softtabstop<
      \ tabstop<
      \ textwidth<
      \ '

setlocal nomodifiable
setlocal noswapfile
setlocal noexpandtab
setlocal nolist
setlocal nonumber
setlocal norelativenumber
setlocal readonly
setlocal scrolloff=999
setlocal shiftwidth=8
setlocal signcolumn=yes
setlocal softtabstop=8
setlocal tabstop=8
setlocal textwidth=200
nnoremap <buffer> q <Cmd>close<CR>

augroup _ft_man_wincmds
  autocmd! * <buffer>
  autocmd BufWinEnter <buffer> nested call execute('wincmd _')
augroup END
