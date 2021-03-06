augroup procon
  autocmd!
  autocmd BufEnter * Procon download
augroup END

command! -nargs=? ProconDownload
\ call procon#download(<f-args>)

command! -nargs=+ ProconPrepare
\ call procon#prepare(<f-args>)

command! ProconBrowse
\ call procon#browse()

command! ProconTest
\ call procon#test()

command! -bang ProconSubmit
\ call procon#submit(<q-bang> ==# '!')

command! -nargs=+ -complete=customlist,procon#commands#complete Procon
\ call procon#commands#call(<f-args>)
