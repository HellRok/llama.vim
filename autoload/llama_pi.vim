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

" Popup on the right side of the window with a margin on top, bottom and right.
" Closes when pi exits; re-running resumes the session via `--continue`.
function! s:open_popup() abort
    let l:dim = s:tmux(['display-message', '-p', '-t', $TMUX_PANE,
        \ '#{window_width} #{window_height}'])
    if empty(l:dim)
        return
    endif
    let [l:ww, l:wh] = map(split(l:dim[0]), 'str2nr(v:val)')
    let l:m = g:llama_pi_popup_margin
    let l:w = l:ww * str2nr(g:llama_pi_popup_width) / 100
    let l:cmd = ['tmux', 'display-popup', '-E', '-t', $TMUX_PANE, '-d', getcwd(),
        \ '-x', string(l:ww - l:w - l:m), '-y', string(l:wh - l:m),
        \ '-w', string(l:w), '-h', string(l:wh - 2 * l:m), g:llama_pi_cmd]
    if has('nvim')
        call jobstart(l:cmd)
    else
        call job_start(l:cmd)
    endif
endfunction

function! llama_pi#open() abort
    if empty($TMUX)
        echohl WarningMsg | echo 'llama_pi: not inside tmux' | echohl None
        return
    endif

    if g:llama_pi_mode ==# 'popup'
        return s:open_popup()
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
