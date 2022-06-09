let s:Promise = vital#atcoder#import('Async.Promise')

function! atcoder#oj#download(url) abort
  lchdir %:h
  return atcoder#_sh('/bin/sh', '-c', 'rm -rf test/ && oj d ' . a:url)
    \.then({-> execute('echomsg "Done!"', '')})
    \.catch({-> execute('echomsg "Error!"', '')})
endfunction

function! atcoder#oj#test() abort
  return atcoder#make()
    \.then({
    \ -> s:Promise.new({resolve, reject
    \ -> term_start(['oj', 'test', '-N', '-c', './program', '-t', '4'], {
      \ 'term_name': 'oj-test',
      \ 'term_rows': 20,
      \ 'exit_cb': {ch, state -> state ? reject() : resolve()},
      \ })})})
endfunction

function! atcoder#oj#submit(bang) abort
  let promise = a:bang ==# ''
    \ ? atcoder#oj#test()
    \.then({-> confirm('Submit?', "&yes\n&No", 0) == 1
    \ ? s:Promise.resolve()
    \ : s:Promise.reject()})
    \ : s:Promise.resolve()
  return promise
    \.then({-> atcoder#bundle()})
    \.then({-> atcoder#_sh('oj', 'submit', '--wait=0', '-y', 'bundle.cpp')})
endfunction
