export default (e) ->
  if e.metaKey or e.altKey or e.ctrlKey
    true
  else
    false
