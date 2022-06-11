let s:Promise = vital#procon#import('Async.Promise')

function! procon#download(url) abort
  lchdir %:h
  call writefile([a:url], expand('%:h') . '/.submit_url')
  return procon#utils#_sh('/bin/sh', '-c', 'rm -rf test/ && oj d ' . a:url)
  \.then({-> execute('echomsg "Done!"', '')})
  \.catch({-> execute('echomsg "Error!"', '')})
endfunction

function! procon#prepare(url) abort
  call procon#utils#_sh('oj-api', 'get-contest', a:url)
  \.then({result -> s:prepare(json_decode(result).result)})
  \.then({-> execute('echomsg "Done!"', '')})
  \.catch({-> execute('echomsg "Error!"', '')})
endfunction

function! s:prepare(result) abort
  let contest_dir = expand('%:h') . '/' . a:result.name . '/'
  for problem in a:result.problems
    let problem_dir = contest_dir . problem.context.alphabet . '/'
    call mkdir(problem_dir, 'p')
    call writefile([problem.url], problem_dir . '.submit_url')
  endfor
endfunction

function! s:lazy_download_test() abort
  let dir = expand('%:h') . '/'
  let url = readfile(dir . 'submit_url')[0]
  call procon#utils#_sh('oj', 'download', url)
  \.then({-> execute('echomsg "Done!"', '')})
  \.catch({-> execute('echoerr "Error!"', '')})
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
  \ readfile(expand('%:h') . '/.submit_url')[0], 'bundle.cpp')})
endfunction
