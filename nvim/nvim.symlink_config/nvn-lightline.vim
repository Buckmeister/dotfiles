let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ] ]
      \ },
      \ 'component': {
      \   'charvaluehex': '0x%B'
      \ },
      \ 'separator': { 'left': "\uE0B4", 'right': "\uE0B6" },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

function! s:lightlineReload()
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction

command! LightlineReload :call s:lightlineReload()
