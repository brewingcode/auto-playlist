export default (e) ->
  if e.metaKey or e.shiftKey or e.altKey or e.ctrlKey
    true
  else
    false
