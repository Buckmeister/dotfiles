let $VIMUSERRUNTIME = fnamemodify($MYVIMRC, ':p:h')

try

if !has('nvim')
  echom "Please use my vim config instead :-)"
  call input("Press any key to continue") | quit
  throw "Please use my vim config instead :-)"
  finish
endif

if !has('nvim-0.5')
  echom "Incompatible Version:"
  echom " -> Please use neovim > 0.5"
  call input("Press any key to continue") | quit
  finish
endif

" == setup ==
source $VIMUSERRUNTIME/nvn-setup.vim

" == basic stuff ==
source $VIMUSERRUNTIME/nvn-general.vim

" == spell ==
source $VIMUSERRUNTIME/nvn-spell.vim

" == overlength ==
source $VIMUSERRUNTIME/nvn-overlength.vim

" == personal mappings ==
source $VIMUSERRUNTIME/nvn-mappings.vim

" == plug ==
source $VIMUSERRUNTIME/nvn-plug.vim

" == vim-vsnip ==
source $VIMUSERRUNTIME/nvn-vsnip.vim

" == nvim-compe ==
source $VIMUSERRUNTIME/nvn-compe.vim

" == goyo ==
source $VIMUSERRUNTIME/nvn-goyo.vim

" == limelight ==
source $VIMUSERRUNTIME/nvn-limelight.vim

" == vim-easy-align ==
source $VIMUSERRUNTIME/nvn-easy-align.vim

" == emmet ==
source $VIMUSERRUNTIME/nvn-emmet.vim

" == haskell-vim ==
source $VIMUSERRUNTIME/nvn-haskell.vim

" == telescope.nvim ==
source $VIMUSERRUNTIME/nvn-telescope.vim

" == manfile settings ==
source $VIMUSERRUNTIME/nvn-man-settings.vim

" == vim-choosewin ==
source $VIMUSERRUNTIME/nvn-choosewin.vim

" == UltiSnips ==
source $VIMUSERRUNTIME/nvn-ultisnips.vim

" == Rnvimr ==
source $VIMUSERRUNTIME/nvn-rnvimr.vim

" == defx ==
source $VIMUSERRUNTIME/nvn-defx.vim

" == which-key ==
source $VIMUSERRUNTIME/nvn-which-key.vim

" == neoformat ==
source $VIMUSERRUNTIME/nvn-neoformat.vim

" == floaterm ==
source $VIMUSERRUNTIME/nvn-floaterm.vim

" == vim-lightline ==
source $VIMUSERRUNTIME/nvn-lightline.vim

" == vim-airline ==
source $VIMUSERRUNTIME/nvn-airline.vim

" == statusline switch ==
source $VIMUSERRUNTIME/nvn-statusline-switcher.vim

" == custom highlights ==
source $VIMUSERRUNTIME/nvn-custom-highlights.vim

" == colorscheme ==
"
" == the following colorschemes are preinstalled ==
" == and can be activated by uncommenting one of ==
" == the following configuration files below ... ==
"
" source $VIMUSERRUNTIME/nvn-cs-edge.vim
" source $VIMUSERRUNTIME/nvn-cs-everforest.vim
" source $VIMUSERRUNTIME/nvn-cs-gruvbox-material.vim
" source $VIMUSERRUNTIME/nvn-cs-onedark.vim
" source $VIMUSERRUNTIME/nvn-cs-sonokai.vim
"
function! s:colors_set(schemename)
  let s:statusline_theme = substitute(a:schemename, "-", "_", "g")
  let g:lightline.colorscheme=s:statusline_theme
  let g:airline_theme=s:statusline_theme

  execute('silent! source $VIMUSERRUNTIME/nvn-cs-'. a:schemename .'.vim')
  execute('silent! StatuslineSet '. g:statusline_current)
endfunction

command! -nargs=1 ColorsSet :call s:colors_set(<q-args>)

if executable('tmux') && strlen($TMUX)
  let g:tui_colorscheme = 'onedark'
else
  let g:tui_colorscheme = 'gruvbox-material'
endif

call s:colors_set(g:tui_colorscheme)

" == init.lua ==
lua require('init')

catch
  echo 'Caught "' . v:exception . '" in ' . v:throwpoint
endtry
