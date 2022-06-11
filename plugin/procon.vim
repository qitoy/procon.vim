command! -nargs=1 OjDownload
  \ call procon#oj#download(<q-args>)

command! OjTest
  \ call procon#oj#test()

command! -bang OjSubmit
  \ call procon#oj#submit(<q-bang>)

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
