" autoload/llama_pi.vim - open/focus a pi session in a tmux pane

let s:pane = ''

function! s:tmux(args) abort
    let l:out = systemlist(['tmux'] + a:args)
    return v:shell_error ? [] : l:out
endfunction

" Is our pane still alive in the current tmux window?
function! s:pane_alive() abort
    if empty(s:pane)
        return 0
    endif
    let l:ids = s:tmux(['list-panes', '-t', $TMUX_PANE, '-F', '#{pane_id}'])
    return index(l:ids, s:pane) >= 0
endfunction

function! llama_pi#open() abort
    if empty($TMUX)
        echohl WarningMsg | echo 'llama_pi: not inside tmux' | echohl None
        return
    endif

    if s:pane_alive()
        call s:tmux(['select-pane', '-t', s:pane])
        return
    endif

    " Full-height pane on the right, 1/3 of the window. `-c` resumes the last
    " pi session for this cwd (pi starts a new one if there is none).
    let l:out = s:tmux(['split-window', '-h', '-f', '-l', g:llama_pi_width,
        \ '-c', getcwd(), '-t', $TMUX_PANE, '-P', '-F', '#{pane_id}',
        \ g:llama_pi_cmd])
    if empty(l:out)
        echohl ErrorMsg | echo 'llama_pi: tmux split-window failed' | echohl None
        return
    endif
    let s:pane = l:out[0]
endfunction
