function speedometer#formatters#default#to_string(metrics)
  return printf('¶ %4d', a:metrics['chars'])
endfunction
