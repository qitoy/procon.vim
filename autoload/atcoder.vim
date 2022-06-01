let s:Promise = vital#atcoder#new().import('Async.Promise')

function atcoder#make(...) abort
	update
	cexpr ""
	let cmd = ["make"] + a:000
	return s:Promise.new({resolve, reject -> job_start(cmd, {
		\ "err_cb": {ch, mes -> execute("caddexpr mes")},
		\ "exit_cb": {ch, state -> state ? reject() : resolve()},
		\ })})
endfunction

function atcoder#make_then(cmd) abort
	return atcoder#make().then({-> execute(a:cmd)})
endfunction

function atcoder#bundle() abort
	return s:Promise.new({resolve, reject -> job_start(["/bin/sh", "-c", "oj-bundle -I ~/AtCoder/C++/library/ main.cpp | sed -e '/#line/d'"], {
		\ "out_io": "file",
		\ "out_name": "bundle.cpp",
		\ "exit_cb": {ch, state -> state ? reject() : resolve()},
		\ })})
endfunction
