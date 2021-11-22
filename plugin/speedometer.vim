" vim: et ts=2 sts=2 sw=2 fdm=marker

" TODO: Check for any needed vim functions
if
      \ !exists('*wordcount')
      \ || !exists('*timer_start')
      \ || get(g:, 'speedometer_loaded', 0)
  finish
endif

let g:speedometer_loaded = 1

" get wordcount
function! g:SpeedometerValue()
  return speedometer#get()
endfunction

" airline functions
if !empty(globpath(&runtimepath, 'plugin/airline.vim', 1))
  function! g:SpeedometerAirlinePlugin(...)
    function! g:SpeedometerAirlineFormat()
      let str = g:SpeedometerValue()
      return str . g:airline_symbols.space . g:airline_right_alt_sep . g:airline_symbols.space
    endfunction

    let filetypes = get(g:, 'airline#extensions#wordcount#filetypes',
      \ ['asciidoc', 'help', 'mail', 'markdown', 'org', 'rst', 'tex', 'text'])
    if index(filetypes, &filetype) > -1
      call airline#extensions#prepend_to_section(
          \ 'z', '%{SpeedometerAirlineFormat()}')
    endif
  endfunction

  call airline#add_statusline_func('SpeedometerAirlinePlugin')
endif
