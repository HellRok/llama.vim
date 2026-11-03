if exists('g:loaded_llama_pi') | finish | endif
let g:loaded_llama_pi = 1

" Independent of g:llama_config.
let g:llama_pi_width  = get(g:, 'llama_pi_width',  '33%')
let g:llama_pi_cmd    = get(g:, 'llama_pi_cmd',    'pi --continue')
let g:llama_pi_keymap = get(g:, 'llama_pi_keymap', '<leader>po')

command! PiOpen call llama_pi#open()
if g:llama_pi_keymap != ''
    exe 'nnoremap <silent> ' . g:llama_pi_keymap . ' :PiOpen<CR>'
endif
