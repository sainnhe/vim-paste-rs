" =============================================================================
" URL: https://github.com/sainnhe/vim-paste-rs
" Filename: autoload/paste_rs.vim
" Author: Sainnhe Park
" Email: sainnhe@gmail.com
" License: GPL3
" =============================================================================

function paste_rs#get_configuration() abort "{{{
  return {
        \ 'register': get(g:, 'paste_rs_register', '+'),
        \ 'yank_url': get(g:, 'paste_rs_yank_url', 'ask'),
        \ 'open_url': get(g:, 'paste_rs_open_url', 'ask'),
        \ }
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
  return lines
endfunction "}}}
function paste_rs#get_buffer() abort "{{{
  return getline(1,'$')
endfunction "}}}
function paste_rs#yank(url, register, interaction) abort "{{{
  if a:interaction ==# 'no'
    return
  elseif a:interaction ==# 'yes'
    call setreg(a:register, a:url)
  else
    if input('Yank to ' . a:register . ' register? [Y/n]') !=# 'n'
      call setreg(a:register, a:url)
    endif
    redraw
  endif
endfunction "}}}
function paste_rs#open(url, interaction) abort "{{{
  if a:interaction ==# 'no'
    return
  elseif a:interaction ==# 'yes'
    if has('win32')
      call system('explorer ' . a:url)
    elseif has('mac')
      call system('open ' . a:url)
    else
      call system('xdg-open ' . a:url)
    endif
  else
    if input('Open URL with default browser? [Y/n]') !=# 'n'
      if has('win32')
        call system('explorer ' . a:url)
      elseif has('mac')
        call system('open ' . a:url)
      else
        call system('xdg-open ' . a:url)
      endif
    endif
    redraw
  endif
endfunction "}}}
function paste_rs#get_url(...) abort "{{{
  if a:0 == 1
    let text = paste_rs#get_selection(a:1)
  else
    let text = paste_rs#get_buffer()
  endif
  let temp_file_path = tempname()
  call writefile(text, temp_file_path, 'a')
  if has('win32')
    let orig_vars = {
          \ 'shell': &shell,
          \ 'shellcmdflag': &shellcmdflag,
          \ 'shellquote': &shellquote,
          \ 'shellxquote': &shellxquote
          \ }
    set shell=powershell
    set shellcmdflag=-c
    set shellquote=\"
    set shellxquote=
    let url_raw = split(system('Invoke-RestMethod -Uri "https://paste.rs" -Method Post -InFile ' . temp_file_path), "\n")
    execute 'set shell=' . orig_vars.shell
    execute 'set shellcmdflag=' . orig_vars.shellcmdflag
    execute 'set shellquote=' . orig_vars.shellquote
    execute 'set shellxquote=' . orig_vars.shellxquote
  else
    let url_raw = split(system('curl --silent --data-binary @' . temp_file_path . ' https://paste.rs/'), "\n")
  endif
  call delete(temp_file_path)
  let url_ext = expand('%:e')
  let url = url_ext ==# '' ?
        \ url_raw[0] :
        \ url_raw[0] . '.' . url_ext
  let configuration = paste_rs#get_configuration()
  call paste_rs#yank(url, configuration.register, configuration.yank_url)
  call paste_rs#open(url, configuration.open_url)
  echohl WarningMsg | echo url | echohl None
endfunction "}}}
function paste_rs#delete(url) abort "{{{
  if has('win32')
    let orig_vars = {
          \ 'shell': &shell,
          \ 'shellcmdflag': &shellcmdflag,
          \ 'shellquote': &shellquote,
          \ 'shellxquote': &shellxquote
          \ }
    set shell=powershell
    set shellcmdflag=-c
    set shellquote=\"
    set shellxquote=
    let info = split(system('Invoke-RestMethod -Uri ' . a:url . ' -Method Delete'), "\n")
    execute 'set shell=' . orig_vars.shell
    execute 'set shellcmdflag=' . orig_vars.shellcmdflag
    execute 'set shellquote=' . orig_vars.shellquote
    execute 'set shellxquote=' . orig_vars.shellxquote
  else
    let info = split(system('curl --silent -X DELETE ' . a:url), "\n")
  endif
  echohl WarningMsg | echo info[0] | echohl None
endfunction "}}}

" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=marker fmr={{{,}}}:
