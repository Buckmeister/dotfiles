let g:statusline_default='lightline'
let g:statusline_current=g:statusline_default

function! s:statusline_set(pluginname)
  if a:pluginname=='airline'
    :AirlineReload
  endif
  if a:pluginname=='lightline'
    :LightlineReload
  endif
  let g:statusline_current=a:pluginname
endfunction

command! -nargs=1 StatuslineSet :call s:statusline_set(<q-args>)
execute('StatuslineSet '. g:statusline_current )
