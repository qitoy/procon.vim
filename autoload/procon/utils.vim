let s:Promise = vital#procon#import('Async.Promise')

function! procon#utils#make(...) abort
  update
  lcd %:p:h
  cexpr ''
  let cmd = ['make'] + a:000
  return s:Promise.new({resolve, reject -> job_start(cmd, {
    \ 'callback': {ch, mes -> execute('caddexpr mes')},
    \ 'exit_cb': {ch, state -> state ? reject() : resolve()},
    \ })})
endfunction

function! procon#utils#make_then(cmd) abort
  return procon#utils#make().then({-> execute(a:cmd)})
endfunction

function! s:read(chan, part) abort
  let out = []
  while ch_status(a:chan, {'part' : a:part}) =~# 'open\|buffered'
    call add(out, ch_read(a:chan, {'part' : a:part}))
  endwhile
  return join(out, '\n')
endfunction

function! procon#utils#_sh(...) abort
  let cmd = a:000
  return s:Promise.new({resolve, reject -> job_start(cmd, {
  \ 'drop' : 'never',
  \ 'close_cb' : {ch -> 'do nothing'},
  \ 'exit_cb' : {ch, code ->
  \   code ? reject(s:read(ch, 'err')) : resolve(s:read(ch, 'out'))
  \ },
  \})})
endfunction
