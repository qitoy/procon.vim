let s:Promise = vital#atcoder#new().import('Async.Promise')

function atcoder#acc#prepare(id) abort
	let s:acc_path = getcwd() . "/" . a:id
	call system("acc n --no-tests " . a:id)
	execute v:shell_error ? "echoerr 'Error!'" : "echomsg 'Done!'"
endfunction

function atcoder#acc#cd(dir) abort
	let dir = s:acc_path . "/" . a:dir . "/"
	if isdirectory(dir) == v:false
		echoerr "The directory is not exists!!"
		return
	endif
	execute("edit " . dir . "main.cpp")
	execute("lcd " . dir)
	if isdirectory("test") == v:false
		let s:job = job_start(["/bin/sh", "-c", "oj d `acc task -u`"], {
			\ "exit_cb": {
				\ ch, state ->
				\ execute(state ? "echoerr 'Error!'" : "echomsg 'Done!'" , "")
				\ }
				\ })
	endif
endfunction

function atcoder#acc#test() abort
	return atcoder#oj#test()
endfunction

function atcoder#acc#submit(bang) abort
	let promise = a:bang ==# ''
		\ ? atcoder#acc#test()
		\.then({-> confirm("Submit?", "&yes\n&No", 0) == 1
			\ ? s:Promise.resolve()
			\ : s:Promise.reject()})
		\ : s:Promise.resolve()
	return promise
		\.then({-> atcoder#bundle()})
		\.then({-> job_start("acc s -s -- --wait=0 -y", {
			\ "exit_cb": {ch, state -> state ? s:Promise.reject() : s:Promise.resolve()},
			\ })})
endfunction
