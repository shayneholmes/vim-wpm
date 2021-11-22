" vim: et ts=2 sts=2 sw=2 fdm=marker

" wrapper {{{1
function! speedometer#get()
  if !exists('b:speedometer_enabled')
    call s:setup_timer()
    let b:speedometer_enabled = 1
  endif

  if !s:is_cache_valid()
    call s:update_speedometer()
  endif

  return get(b:, 'speedometer_timer_id', 0)  .. '+' .. b:speedometer_result
endfunction

" caching {{{1
function s:is_cache_valid()
  return exists('b:speedometer_result')
endfunction

" timer {{{1
function! s:setup_timer()
  augroup speedometer
    autocmd InsertEnter * call speedometer#start_speedometer()
    autocmd InsertLeavePre * call speedometer#stop_speedometer()
endfunction

function speedometer#start_speedometer()
  echom "Starting speedometer"
  let b:speedometer_timer_id = timer_start(1000, {-> s:update_speedometer()}, {'repeat': -1})
endfunction

function speedometer#stop_speedometer()
  if !exists('b:speedometer_timer_id')
    return
  endif
  call timer_stop(b:speedometer_timer_id)
endfunction

" computation {{{1
function s:update_speedometer()
  let b:speedometer_calls = get(b:, 'speedometer_calls', 0) + 1
  let l:wordcount = s:get_wordcount()
  " TODO
  " Initialize ring buffer
  " Update ring buffer
  " Compare against old value to get speed
  let b:speedometer_result = l:wordcount .. 'w, #' .. b:speedometer_calls
  redraw!
endfunction

function s:get_wordcount()
  return wordcount()['chars'] / 5
endfunction

" formatting {{{1
let s:formatter = get(g:, 'speedometer#formatter', 'default')

" convenience function to interface with the formatter call
function! s:format_wordcount(metrics)
  return speedometer#formatters#{s:formatter}#to_string(a:metrics)
endfunction

" check that the formatter exists, otherwise fall back to default
if s:formatter !=# 'default'
  execute 'runtime! autoload/speedometer/formatters/'.s:formatter.'.vim'
  if !exists('*speedometer#formatters#{s:formatter}#to_string')
    let s:formatter = 'default'
  endif
endif
