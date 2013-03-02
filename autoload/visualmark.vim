" ---------------------------------------------------------------------
"  GetVimCmdOutput:
" Stole from Hari Krishna Dara's genutils.vim (http://vim.sourceforge.net/scripts/script.php?script_id=197)
"  to ease the scripts dependency issue
fun! visualmark#GetVimCmdOutput(cmd)

  " Save the original locale setting for the messages
  let old_lang = v:lang

  " Set the language to English
  exec ":lan mes en_US"

  let v:errmsg = ''
  let output   = ''
  let _z       = @z

  try
    redir @z
    silent exe a:cmd
  catch /.*/
    let v:errmsg = substitute(v:exception, '^[^:]\+:', '', '')
  finally
    redir END
    if v:errmsg == ''
      let output = @z
    endif
    let @z = _z
  endtry

  " Restore the original locale
  exec ":lan mes " . old_lang

  return output
endfun

" ---------------------------------------------------------------------
"  Vm_place_sign:
fun! visualmark#Vm_place_sign()

  if !exists("b:Vm_sign_number")
    let b:Vm_sign_number = 1
  endif

  let ln = line(".")

  exe 'sign define SignSymbol linehl=SignColor texthl=SignColor'
  exe 'sign place ' . b:Vm_sign_number . ' line=' . ln . ' name=SignSymbol buffer=' . winbufnr(0)

  let vsn              = b:Vm_sign_number
  let b:Vm_sign_number = b:Vm_sign_number + 1

  if &bg == "dark"
   highlight SignColor ctermfg=white ctermbg=blue guifg=white guibg=RoyalBlue3
  else
   highlight SignColor ctermbg=white ctermfg=blue guibg=grey guifg=RoyalBlue3
  endif

endfun

" ---------------------------------------------------------------------
" Vm_remove_sign:
fun! visualmark#Vm_remove_sign(sign_id)
  silent! exe 'sign unplace ' . a:sign_id . ' buffer=' . winbufnr(0)
endfun

" ---------------------------------------------------------------------
" Vm_remove_all_signs:
fun! visualmark#Vm_remove_all_signs()
  silent! exe 'sign unplace *'
endfun

" ---------------------------------------------------------------------
" Vm_get_sign_id_from_line:
fun! visualmark#Vm_get_sign_id_from_line(line_number)

  let sign_list = visualmark#GetVimCmdOutput('sign place buffer=' . winbufnr(0))
"  call Decho(sign_list)

  let line_str_index = match(sign_list, "line=" . a:line_number, 0)
  if line_str_index < 0
    return -1
  endif

  let id_str_index = matchend(sign_list, "id=", line_str_index)
"  let tmp = strpart(sign_list, id_str_index, 10)   "Decho
"  call Decho("ID str index: " . tmp)
  if id_str_index < 0
    return -1
  endif

  let space_index = match(sign_list, " ", id_str_index)
  let id          = strpart(sign_list, id_str_index, space_index - id_str_index)

  return id
endfun

" ---------------------------------------------------------------------
" Vm_toggle_sign:
fun! visualmark#Vm_toggle_sign()

  let curr_line_number = line(".")
  let sign_id          = visualmark#Vm_get_sign_id_from_line(curr_line_number)

  if sign_id < 0
    let is_on = 0
  else
    let is_on = 1
  endif

  if (is_on != 0)
    call visualmark#Vm_remove_sign(sign_id)
  else
    call visualmark#Vm_place_sign()
  endif

endfun

" ---------------------------------------------------------------------
" Vm_get_line_number:
fun! visualmark#Vm_get_line_number(string)

  let line_str_index = match(a:string, "line=", b:Vm_start_from)
  if line_str_index <= 0
    return -1
  endif

  let equal_sign_index = match(a:string, "=", line_str_index)
  let space_index      = match(a:string, " ", equal_sign_index)
  let line_number      = strpart(a:string, equal_sign_index + 1, space_index - equal_sign_index - 1)
  let b:Vm_start_from  = space_index

  return line_number + 0
endfun

" ---------------------------------------------------------------------
" Vm_get_next_sign_line:
fun! visualmark#Vm_get_next_sign_line(curr_line_number)

  let b:Vm_start_from = 1
  let sign_list = visualmark#GetVimCmdOutput('sign place buffer=' . winbufnr(0))
  " call Decho("sign_list<".sign_list.">")

  let curr_line_number = a:curr_line_number
  let line_number = 1
  let is_no_sign  = 1
  let min_line_number = -1
  let min_line_number_diff = 0
  
  while 1
    let line_number = visualmark#Vm_get_line_number(sign_list)
    if line_number < 0
      break
    endif

    " Record the very first line that has a sign
    if is_no_sign != 0 
      let min_line_number = line_number
    elseif line_number < min_line_number
      let min_line_number = line_number
    endif
    let is_no_sign = 0

    " let tmp_diff = curr_line_number - line_number
    let tmp_diff = line_number - curr_line_number
    if tmp_diff > 0
      " line_number is below curr_line_number
      if min_line_number_diff > 0 
        if tmp_diff < min_line_number_diff
          let min_line_number_diff = tmp_diff
        endif
      else
        let min_line_number_diff = tmp_diff
      endif
    endif

  endwhile

  let line_number = curr_line_number + min_line_number_diff

  if is_no_sign != 0 || min_line_number_diff <= 0
    let line_number = min_line_number
  endif

  return line_number
endfun

" ---------------------------------------------------------------------
" Vm_get_prev_sign_line:
fun! visualmark#Vm_get_prev_sign_line(curr_line_number)

  let b:Vm_start_from = 1
  let sign_list = visualmark#GetVimCmdOutput('sign place buffer=' . winbufnr(0))

  let curr_line_number = a:curr_line_number
  let line_number = 1
  let is_no_sign  = 1
  let max_line_number = -1
  let max_line_number_diff = 0
  
  while 1
    let line_number = visualmark#Vm_get_line_number(sign_list)
    if line_number < 0
      break
    endif

    " Record the very first line that has a sign
    if is_no_sign != 0 
      let max_line_number = line_number
    elseif line_number > max_line_number 
      let max_line_number = line_number
    endif
    let is_no_sign = 0

    let tmp_diff = curr_line_number - line_number
    if tmp_diff > 0
      " line_number is below curr_line_number
      if max_line_number_diff > 0 
        if tmp_diff < max_line_number_diff 
          let max_line_number_diff = tmp_diff
        endif
      else
        let max_line_number_diff = tmp_diff
      endif
    endif

  endwhile

  let line_number = curr_line_number - max_line_number_diff 

  if is_no_sign != 0 || max_line_number_diff <= 0
    let line_number = max_line_number 
  endif

  return line_number
endfun

" ---------------------------------------------------------------------
" Vm_goto_next_sign:
fun! visualmark#Vm_goto_next_sign()

  let curr_line_number      = line(".")
  let next_sign_line_number = visualmark#Vm_get_next_sign_line(curr_line_number)

  if next_sign_line_number >= 0
    exe ":" . next_sign_line_number
  endif

endfun

" ---------------------------------------------------------------------
" Vm_goto_prev_sign:
fun! visualmark#Vm_goto_prev_sign()

  let curr_line_number      = line(".")
  let prev_sign_line_number = visualmark#Vm_get_prev_sign_line(curr_line_number)

  if prev_sign_line_number >= 0
    exe prev_sign_line_number 
  endif

endfun

" ---------------------------------------------------------------------
