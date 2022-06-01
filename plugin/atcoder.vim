command! -nargs=1 OjDownload
	\ call atcoder#oj#download(<q-args>)

command! OjTest
	\ call atcoder#oj#test()

command! -bang OjSubmit
	\ call atcoder#oj#submit(<q-bang>)

command! -nargs=1 AccPrepare
	\ call atcoder#acc#prepare(<q-args>)

command! -nargs=1 AccCd
	\ call atcoder#acc#cd(<q-args>)

command! AccTest
	\ call atcoder#acc#test()

command! -bang AccSubmit
	\ call atcoder#acc#submit(<q-bang>)
