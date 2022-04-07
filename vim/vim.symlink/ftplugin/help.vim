setlocal textwidth=200
nnoremap <buffer> <CR> <C-]>
nnoremap <buffer> <BS> <C-T>
nnoremap <buffer> o /'\l\{2,\}'<CR>
nnoremap <buffer> O ?'\l\{2,\}'<CR>
nnoremap <buffer> s /\|\zs\S\+\ze\|<CR>
nnoremap <buffer> S ?\|\zs\S\+\ze\|<CR>
nnoremap <buffer> q <Cmd>close<CR>
autocmd BufWinEnter <buffer> if &l:buftype ==# 'help' | wincmd _ | endif

