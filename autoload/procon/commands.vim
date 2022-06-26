function! procon#commands#complete(arglead, cmdline, cursorpos) abort
  let cmd = ['download', 'prepare', 'browse', 'test', 'submit', 'addtest']
  return filter(cmd, {_, val -> stridx(val, a:arglead) == 0})
endfunction

function! procon#commands#call(command, ...) abort
  let Func = function('procon#' . a:command, a:000)
  call Func()
endfunction
