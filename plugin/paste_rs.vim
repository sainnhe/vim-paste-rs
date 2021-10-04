" =============================================================================
" URL: https://github.com/sainnhe/vim-paste-rs
" Filename: plugin/paste_rs.vim
" Author: Sainnhe Park
" Email: sainnhe@gmail.com
" License: GPL3
" =============================================================================

xnoremap <silent> <Plug>(paste-rs) :<C-u>call paste_rs#get_url(visualmode())<Cr>
nnoremap <silent> <Plug>(paste-rs) :<C-u>call paste_rs#get_url()<Cr>
command -nargs=1 -range PasteRsDelete call paste_rs#delete(<args>)
command -nargs=0 -range PasteRsAddBuffer call paste_rs#get_url()
command -nargs=0 -range PasteRsAddSelection call paste_rs#get_url(visualmode())
