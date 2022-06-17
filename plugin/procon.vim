augroup procon
  autocmd!
augroup END

command! -nargs=? ProconDownload
\ call procon#download(<q-args>)

command! -nargs=1 ProconPrepare
\ call procon#prepare(<q-args>)

command! ProconBrowse
\ call procon#browse()

command! ProconTest
\ call procon#test()

command! -bang ProconSubmit
\ call procon#submit(<q-bang>)
