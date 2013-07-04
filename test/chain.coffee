# since triggers are pushed to the end of the callstack, we need to push our
# assertions back further

fn = (arr) ->
  next = ->
    nextFn = arr.shift()
    if nextFn instanceof Function
      try nextFn()
      catch e
        console.error(e)
        throw e
      setTimeout(next, 2)
    else console.log('ok')
  setTimeout(next, 2)

module.exports = fn
