function speedometer#formatters#default#to_string(metrics)
  return printf('%4dwpm', a:metrics['wpm'])
endfunction
