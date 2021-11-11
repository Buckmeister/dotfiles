set background=dark

let colorterm=$COLORTERM
if colorterm=="truecolor" || colorterm=="24bit"
  let g:onedark_terminal_italics = 1
else
  let g:onedark_terminal_italics = 0
endif

silent! colorscheme onedark

