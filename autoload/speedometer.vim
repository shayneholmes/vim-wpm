" vim: et ts=2 sts=2 sw=2 fdm=marker

let s:lookback_periods = get(g:, 'speedometer#lookback', 10)
" let g:speedometer#formatter = 'debug'

" wrapper {{{1
function! speedometer#get()
  if !exists('b:speedometer_enabled')
    call s:setup_timer()
    let b:speedometer_enabled = 1
  endif

  if !s:is_cache_valid()
    call s:update_speedometer()
  endif

  return s:format(b:speedometer_result)
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
  augroup END
endfunction

function speedometer#start_speedometer()
  if exists('b:speedometer_timer_id')
    return
  endif
  let b:speedometer_timer_id = timer_start(1000, {-> s:update_speedometer()}, {'repeat': -1})
endfunction

function speedometer#stop_speedometer()
  if !exists('b:speedometer_timer_id')
    return
  endif
  call timer_stop(b:speedometer_timer_id)
  unlet b:speedometer_timer_id
endfunction

" computation {{{1
function s:update_speedometer()
  let b:speedometer_updates = get(b:, 'speedometer_updates', 0) + 1
  " Compute current count
  let l:wordcount = s:get_wordcount()
  if !exists('b:speedometer_counts_over_time')
    " Initialize ring buffer and vars needed to manage it.
    " First, the ring buffer.
    let b:speedometer_counts_over_time = []
    " Boolean state variable that indicates whether we've filled the ring
    " buffer.
    let b:speedometer_full = 0
    " Index of the next location in the ring buffer to be filled. New data will be placed here.
    let b:speedometer_next_index = 0
  endif
  " Update ring buffer, set last count and period
  if !b:speedometer_full
    " We're creating the ring buffer, and it isn't long enough yet. Add an
    " entry.
    let b:speedometer_counts_over_time = add(b:speedometer_counts_over_time, 0)
    if !b:speedometer_next_index
      " Very first iteration: 0 wpm
      let l:last_count = l:wordcount
      let l:period = 1 " Avoid division by zero
    else
      " The ring buffer isn't full, so check over however long we can.
      let l:last_count = b:speedometer_counts_over_time[0]
      let l:period = b:speedometer_next_index
    endif
  else
    " We've filled the lookback buffer, so compare against the entry we'll
    " replace in the buffer: It holds the value from last time we went through.
    let l:last_count = b:speedometer_counts_over_time[b:speedometer_next_index]
    let l:period = s:lookback_periods
  endif
  " Calculate speed
  let l:wpm = float2nr((l:wordcount - l:last_count) * 60 / l:period)
  " Update entry in ring buffer
  let b:speedometer_counts_over_time[b:speedometer_next_index] = l:wordcount
  " Update pointer
  let b:speedometer_next_index = (b:speedometer_next_index + 1) % s:lookback_periods
  if b:speedometer_next_index == 0
    let b:speedometer_full = 1
  endif
  " Return result
  let b:speedometer_result = {
        \ 'words': l:wordcount,
        \ 'updates': b:speedometer_updates,
        \ 'wpm': l:wpm,
        \ 'seconds': l:period,
        \ }
  redraw!
endfunction

function s:get_wordcount()
  return wordcount()['chars'] / 5.0
endfunction

" formatting {{{1
let s:formatter = get(g:, 'speedometer#formatter', 'default')

" convenience function to interface with the formatter call
function! s:format(metrics)
  return speedometer#formatters#{s:formatter}#to_string(a:metrics)
endfunction

" check that the formatter exists, otherwise fall back to default
if s:formatter !=# 'default'
  execute 'runtime! autoload/speedometer/formatters/'.s:formatter.'.vim'
  if !exists('*speedometer#formatters#{s:formatter}#to_string')
    let s:formatter = 'default'
  endif
endif
