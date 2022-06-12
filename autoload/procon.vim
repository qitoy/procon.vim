let s:Promise = vital#procon#import('Async.Promise')
let s:File = vital#procon#import('System.File')

function! procon#download(url) abort
  let dir = expand('%:p:h') . '/'
  if a:url ==# ''
    let url = readfile(dir . '.contest_url')[0]
  else
    let url = a:url
    call writefile([url], dir . '.contest_url')
  endif
  let test_dir = dir . 'test/'
  return procon#utils#_sh('rm', '-rf', test_dir)
  \.then({-> procon#utils#_sh('oj', 'download', '-d', test_dir, url)})
  \.then({-> execute('echomsg "Done!"', '')})
  \.catch({mes -> execute('echoerr mes', '')})
endfunction

function! procon#prepare(url) abort
  call procon#utils#_sh('oj-api', 'get-contest', a:url)
  \.then({result -> s:prepare(json_decode(result).result)})
  \.then({-> execute('echomsg "Done!"', '')})
  \.catch({mes -> execute('echoerr mes', '')})
endfunction

function! s:prepare(result) abort
  let contest_dir = expand('%:p:h') . '/' . a:result.name . '/'
  for problem in a:result.problems
    let problem_dir = contest_dir . problem.context.alphabet . '/'
    call mkdir(problem_dir, 'p')
    call writefile([problem.url], problem_dir . '.contest_url')
    call s:File.copy(expand('~') . '/Library/Preferences/atcoder-cli-nodejs/cpp/main.cpp', problem_dir . 'main.cpp')
    call s:File.copy(expand('~') . '/Library/Preferences/atcoder-cli-nodejs/cpp/Makefile', problem_dir . 'Makefile')
    execute 'autocmd procon BufEnter' substitute(problem_dir, ' ', '\\ ', 'g') . 'main.cpp'
    \ '++once' 'call procon#download("")'
  endfor
endfunction

function! procon#browse() abort
  call openbrowser#load()
  let url = readfile(expand('%:p:h') . '/.contest_url')[0]
  call openbrowser#open(url)
endfunction

function! procon#test() abort
  return procon#utils#make()
  \.then({
  \ -> s:Promise.new({resolve, reject
  \ -> term_start(['oj', 'test', '-N', '-c', './program', '-t', '4'], {
    \ 'term_name': 'oj-test',
    \ 'term_rows': 20,
    \ 'exit_cb': {ch, state -> state ? reject() : resolve()},
    \ })})})
endfunction

function! procon#submit(bang) abort
  let promise = a:bang ==# ''
  \ ? procon#test()
  \.then({-> confirm('Submit?', "&yes\n&No", 0) == 1
  \ ? s:Promise.resolve()
  \ : s:Promise.reject()})
  \ : s:Promise.resolve()
  return promise
  \.then({-> procon#utils#bundle()})
  \.then({-> procon#utils#_sh('oj', 'submit', '--wait=0', '-y',
  \ readfile(expand('%:p:h') . '/.contest_url')[0], 'bundle.cpp')})
endfunction
