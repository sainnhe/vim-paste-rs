" =============================================================================
" URL: https://github.com/sainnhe/vim-paste-rs
" Filename: autoload/paste_rs.vim
" Author: Sainnhe Park
" Email: sainnhe@gmail.com
" License: GPL3
" =============================================================================

function paste_rs#get_url(...) abort "{{{
  if a:0 == 1
    let text = paste_rs#get_selection(a:1)
  else
    let text = paste_rs#get_buffer()
  endif
  let url = system('echo ' . shellescape(text) . ' | curl --silent --data-binary @- https://paste.rs/')
  if input('Yank to + register? [y/N]') == 'y'
    call setreg('+', url)
  endif
  redraw
  echohl WarningMsg | echo url | echohl None
endfunction "}}}
function paste_rs#get_selection(mode) abort "{{{
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end]     = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if a:mode ==# 'v'
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
  elseif a:mode ==# 'V'
  elseif a:mode == "\<c-v>"
    let new_lines = []
    let i = 0
    for line in lines
      let lines[i] = line[column_start - 1: column_end - (&selection == 'inclusive' ? 1 : 2)]
      let i = i + 1
    endfor
  else
    return ''
  endif
  return join(lines, "\n")
endfunction "}}}
function paste_rs#get_buffer() abort "{{{
  return join(getline(1,'$'), "\n")
endfunction "}}}

" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=marker fmr={{{,}}}:
