function! atcoder#acc#prepare(id) abort
	let s:acc_path = getcwd() . '/' . a:id
	call system('acc n --no-tests ' . a:id)
	execute v:shell_error ? 'echoerr "Error!"' : 'echomsg "Done!"'
endfunction

function! atcoder#acc#cd(dir) abort
	let dir = s:acc_path . '/' . a:dir . '/'
	if isdirectory(dir) == v:false
		echoerr 'The directory is not exists!!'
		return
	endif
	execute('edit ' . dir . 'main.cpp')
	execute('lcd ' . dir)
	if isdirectory('test') == v:false
		call atcoder#_sh('/bin/sh', '-c', 'oj d `acc task -u`')
			\.then({-> execute('echomsg "Done!"', '')})
			\.catch({-> execute('echomsg "Error!"', '')})
	endif
endfunction

function! atcoder#acc#browse() abort
  return atcoder#_sh('acc', 'task', '-u')
    \.then(function('openbrowser#open'))
endfunction

function! atcoder#acc#test() abort
	return atcoder#oj#test()
endfunction

function! atcoder#acc#submit(bang) abort
	let promise = a:bang ==# ''
		\ ? atcoder#acc#test()
		\.then({-> confirm('Submit?', '&yes\n&No', 0) == 1
			\ ? atcoder#_Promise.resolve()
			\ : atcoder#_Promise.reject()})
		\ : atcoder#_Promise.resolve()
	return promise
		\.then({-> atcoder#bundle()})
		\.then({-> atcoder#_sh('acc', 'submit', '-s', '--', '--wait=0', '-y')})
endfunction
