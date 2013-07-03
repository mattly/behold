# since triggers are pushed to the end of the callstack, we need to push our
# assertions back further

fn = (arr, done) ->
  next = arr.shift()
  if next
    next()
    setTimeout(fn, 1, arr, done)
  else done()

module.exports = fn
