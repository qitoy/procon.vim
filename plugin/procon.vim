augroup procon
  autocmd!
augroup END

command! -nargs=? OjDownload
\ call procon#download(<q-args>)

command! -nargs=1 OjPrepare
\ call procon#prepare(<q-args>)

command! OjBrowse
\ call procon#browse()

command! OjTest
\ call procon#test()

command! -bang OjSubmit
\ call procon#submit(<q-bang>)

command! -nargs=1 AccPrepare
\ call procon#acc#prepare(<q-args>)

command! -nargs=1 AccCd
\ call procon#acc#cd(<q-args>)

command! AccBrowse
\ call procon#acc#browse()

command! AccTest
\ call procon#acc#test()

command! -bang AccSubmit
\ call procon#acc#submit(<q-bang>)
