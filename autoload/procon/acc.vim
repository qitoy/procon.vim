let s:Promise = vital#procon#import('Async.Promise')

function! procon#acc#prepare(id) abort
  let s:acc_path = getcwd() . '/' . a:id
  return procon#utils#_sh('acc', 'new', '--no-tests', a:id)
    \.then({-> execute('echomsg "Done!"', '')})
    \.catch({-> execute('echoerr "Error!"', '')})
endfunction

function! procon#acc#cd(dir) abort
  let dir = s:acc_path . '/' . a:dir . '/'
  if isdirectory(dir) == v:false
    echoerr 'The directory is not exists!!'
    return
  endif
  execute('edit ' . dir . 'main.cpp')
  execute('lcd ' . dir)
  if isdirectory('test') == v:false
    call procon#utils#_sh('/bin/sh', '-c', 'oj d `acc task -u`')
      \.then({-> execute('echomsg "Done!"', '')})
      \.catch({-> execute('echomsg "Error!"', '')})
  endif
endfunction

function! procon#acc#browse() abort
  call openbrowser#load()
  return procon#utils#_sh('acc', 'task', '-u')
    \.then(function('openbrowser#open'))
endfunction

function! procon#acc#test() abort
  return procon#test()
endfunction

function! procon#acc#submit(bang) abort
  let promise = a:bang ==# ''
    \ ? procon#acc#test()
    \.then({-> confirm('Submit?', "&yes\n&No", 0) == 1
    \ ? s:Promise.resolve()
    \ : s:Promise.reject()})
    \ : s:Promise.resolve()
  return promise
    \.then({-> procon#utils#bundle()})
    \.then({-> procon#utils#_sh('acc', 'submit', '-s', '--', '--wait=0', '-y')})
endfunction
