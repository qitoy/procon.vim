let s:Promise = vital#procon#import('Async.Promise')

function! procon#download(...) abort
  let dir = expand('%:p:h') . '/'
  let test_dir = dir . 'test/'
  if a:0 == 0
    if !filereadable(dir . '.contest_url') || isdirectory(test_dir)
      return s:Promise.reject()
    endif
    let url = readfile(dir . '.contest_url')[0]
    let promise = s:Promise.resolve()
  else
    let url = a:1
    call writefile([url], dir . '.contest_url')
    let promise = procon#_sh('rm', '-rf', test_dir)
  endif
  return promise
  \.then({-> procon#_sh('oj', 'download', '-d', test_dir, url)})
  \.then({-> execute('echomsg "Done!"', '')})
  \.catch({mes -> [execute('echomsg mes', ''), mkdir(test_dir, 'p')]})
endfunction

function! procon#prepare(url, ...) abort
  let defaultlang = get(g:, 'procon#defaultlang', 'cpp')
  let lang = get(a:000, 0, defaultlang)
  return procon#_sh('oj-api', 'get-contest', a:url)
  \.then({result -> s:prepare(json_decode(result).result, lang)})
  \.then({-> execute('echomsg "Done!"', '')})
  \.catch({mes -> execute('echomsg mes', '')})
endfunction

function! s:prepare(result, lang) abort
  let preference = get(g:, 'procon#preference', expand('~/.procon/'))
  let contest_dir = expand('%:p:h') . '/' . a:result.name . '/'
  let ps = []
  for problem in a:result.problems
    let problem_dir = contest_dir . problem.context.alphabet . '/'
    call mkdir(problem_dir, 'p')
    call writefile([problem.url], problem_dir . '.contest_url')
    call add(ps,
    \ procon#_sh('/bin/bash', '-c',
    \ 'cp ' . preference . a:lang . '/* ' . fnamemodify(problem_dir, ':S')
    \))
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

function! procon#submit(...) abort
  update
  let cwd = expand('%:p:h')
  if get(a:, 1, 0)
    let promise = s:Promise.resolve()
  else
    let promise = procon#test()
    \.then({-> confirm('Submit?', "&yes\n&No", 0) == 1
    \ ? s:Promise.resolve() : s:Promise.reject()})
  endif
  return promise
  \.then({-> readfile(cwd . '/.contest_url')[0]})
  \.then({url -> procon#_sh('make', '-C', cwd, 'submit', 'URL=' . url)})
  \.catch({mes -> execute('echomsg mes', '')})
endfunction

function! s:read(chan, part) abort
  let out = []
  while ch_status(a:chan, {'part' : a:part}) =~# 'open\|buffered'
    call add(out, ch_read(a:chan, {'part' : a:part}))
  endwhile
  return join(out, '\n')
endfunction

function! procon#_sh(...) abort
  let cmd = a:000
  return s:Promise.new({resolve, reject -> job_start(cmd, {
  \ 'drop' : 'never',
  \ 'close_cb' : {ch -> 'do nothing'},
  \ 'exit_cb' : {ch, code ->
  \   code ? reject(s:read(ch, 'err')) : resolve(s:read(ch, 'out'))
  \ },
  \})})
endfunction
