function speedometer#formatters#default#to_string(metrics)
  return printf('%3d', a:metrics.wpm)
endfunction
