augroup procon
  autocmd!
augroup END

command! -nargs=? ProconDownload
\ call procon#download(<q-args>)

command! -nargs=+ ProconPrepare
\ call procon#prepare(<f-args>)

command! ProconBrowse
\ call procon#browse()

command! ProconTest
\ call procon#test()

command! -bang ProconSubmit
\ call procon#submit(<q-bang>)
