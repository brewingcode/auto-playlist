export default (e) ->
  return true if e.metaKey or e.altKey or e.ctrlKey
  return true if e.target?.tagName is 'INPUT'

  return false
