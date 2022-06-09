let s:Promise = vital#atcoder#import('Async.Promise')

function! atcoder#make(...) abort
  update
  cexpr ''
  let cmd = ['make'] + a:000
  return s:Promise.new({resolve, reject -> job_start(cmd, {
    \ 'err_cb': {ch, mes -> execute('caddexpr mes')},
    \ 'exit_cb': {ch, state -> state ? reject() : resolve()},
    \ })})
endfunction

function! atcoder#make_then(cmd) abort
  return atcoder#make().then({-> execute(a:cmd)})
endfunction

function! atcoder#bundle() abort
  return s:Promise.new({resolve, reject -> job_start(['/bin/sh', '-c', 'oj-bundle -I ~/AtCoder/C++/library/ main.cpp | sed -e "/#line/d"'], {
    \ 'out_io': 'file',
    \ 'out_name': 'bundle.cpp',
    \ 'exit_cb': {ch, state -> state ? reject() : resolve()},
    \ })})
endfunction

function! s:read(chan, part) abort
  let out = []
  while ch_status(a:chan, {'part' : a:part}) =~# 'open\|buffered'
    call add(out, ch_read(a:chan, {'part' : a:part}))
  endwhile
  return join(out, '\n')
endfunction

function! atcoder#_sh(...) abort
  let cmd = a:000
  return s:Promise.new({resolve, reject -> job_start(cmd, {
    \ 'drop' : 'never',
    \ 'close_cb' : {ch -> 'do nothing'},
    \ 'exit_cb' : {ch, code ->
    \ code ? reject(s:read(ch, 'err')) : resolve(s:read(ch, 'out'))
    \ },
    \ })})
endfunction
