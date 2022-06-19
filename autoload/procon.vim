let s:Promise = vital#procon#import('Async.Promise')

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
  \.catch({mes -> execute('echomsg mes', '')})
endfunction

function! procon#prepare(url, ...) abort
  let defaultlang = get(g:, 'procon#defaultlang', 'cpp')
  let lang = get(a:000, 0, defaultlang)
  call procon#utils#_sh('oj-api', 'get-contest', a:url)
  \.then({result -> s:prepare(json_decode(result).result, lang)})
  \.then({-> execute('echomsg "Done!"', '')})
  \.catch({mes -> execute('echomsg mes', '')})
endfunction

function! s:prepare(result, lang) abort
  let preference = get(g:, 'procon#preference', expand('~/.procon/'))
  let contest_dir = expand('%:p:h') . '/' . substitute(a:result.url, '^.*/', '', '') . '/'
  let ps = []
  for problem in a:result.problems
    let problem_dir = contest_dir . problem.context.alphabet . '/'
    call mkdir(problem_dir, 'p')
    call writefile([problem.url], problem_dir . '.contest_url')
    call add(ps,
    \ procon#utils#_sh('/bin/bash', '-c', 'cp ' . preference . a:lang . '/* ' . problem_dir))
    execute 'autocmd procon BufEnter' problem_dir . '*'
    \ '++once' 'call procon#download("")'
  endfor
  return s:Promise.all(ps)
endfunction

function! procon#browse() abort
  call openbrowser#load()
  let url = readfile(expand('%:p:h') . '/.contest_url')[0]
  call openbrowser#open(url)
endfunction

function! procon#test() abort
  update
  return s:Promise.new({resolve, reject
  \ -> term_start(['make', 'test'], {
    \ 'cwd': expand('%:p:h'),
    \ 'term_name': 'oj-test',
    \ 'term_rows': 20,
    \ 'exit_cb': {ch, state -> state ? reject() : resolve()},
    \ })})
endfunction

function! procon#submit(bang) abort
  update
  let cwd = expand('%:p:h')
  let promise = a:bang ==# ''
  \ ? procon#test()
  \.then({-> confirm('Submit?', "&yes\n&No", 0) == 1
  \ ? s:Promise.resolve()
  \ : s:Promise.reject()})
  \ : s:Promise.resolve()
  return promise
  \.then({-> readfile(cwd . '/.contest_url')[0]})
  \.then({url -> procon#utils#_sh('make', '-C', cwd, 'submit', 'URL=' . url)})
  \.catch({mes -> execute('echomsg mes', '')})
endfunction
