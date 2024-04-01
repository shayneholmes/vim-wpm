function speedometer#formatters#debug#to_string(metrics)
  return printf('%ds %fw %dwpm %du', a:metrics.seconds, a:metrics.words, a:metrics.wpm, a:metrics.updates)
endfunction
