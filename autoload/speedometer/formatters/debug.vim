function speedometer#formatters#debug#to_string(metrics)
  return printf(
        \ '%d updates | %s',
        \ get(b:, 'speedometer_updates', 0),
        \ a:metrics)
endfunction
