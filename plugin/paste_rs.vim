" =============================================================================
" URL: https://github.com/sainnhe/vim-paste-rs
" Filename: plugin/paste_rs.vim
" Author: Sainnhe Park
" Email: sainnhe@gmail.com
" License: GPL3
" =============================================================================

xnoremap <Plug>(paste-rs) :<C-u>call paste_rs#get_url(visualmode())<Cr>
nnoremap <Plug>(paste-rs) :<C-u>call paste_rs#get_url()<Cr>
