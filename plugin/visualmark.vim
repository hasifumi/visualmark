" Visual Mark
" 2005-10-27, brian wang
"
" Acknowledgements:
"   - Thanks to Hari Krishna Dara's genutils.vim (http://vim.sourceforge.net/scripts/script.php?script_id=197)
"   - Thanks to Mr. Charles E. Campbell, Jr. for making this script more plugin-like :-)
"   - Thanks to Mr. Charles E. Campbell, Jr. for making this script adapt to
"     dark/light backgrounds
"   - Thanks to Evgeny Filatov for noticing a nasty bug in Vm_get_line_number :-)

if exists("loaded_VisualMark")
  finish
endif
let loaded_VisualMark = 1
if !has("signs")
 echoerr "***sorry*** [".expand("%")."] your vim doesn't support signs"
 finish
endif

"" ---------------------------------------------------------------------
""  Public Interface:
"if !hasmapto('<Plug>Vm_toggle_sign')
"    if has('mac')
"        map <unique> <d-F2> <Plug>Vm_toggle_sign
"        map <silent> <unique> mm <Plug>Vm_toggle_sign 
"    else
"        map <unique> <c-F2> <Plug>Vm_toggle_sign
"        map <silent> <unique> mm <Plug>Vm_toggle_sign 
"    endif
"endif
"nnoremap <silent> <script> <Plug>Vm_toggle_sign	:call Vm_toggle_sign()<cr>
"
"if !hasmapto('<Plug>Vm_goto_next_sign')
"  map <unique> <F2> <Plug>Vm_goto_next_sign
"endif
"nnoremap <silent> <script> <Plug>Vm_goto_next_sign	:call Vm_goto_next_sign()<cr>
"
"if !hasmapto('<Plug>Vm_goto_prev_sign')
"  map <unique> <s-F2> <Plug>Vm_goto_prev_sign
"endif
"nnoremap <silent> <script> <Plug>Vm_goto_prev_sign	:call Vm_goto_prev_sign()<cr>
"
