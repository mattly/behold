assert = require('assert')
main = require('../src/index')

obj = { handle: 'mattly' }

beholden = main(obj)

assert.equal(obj._behold, beholden)
assert.ok(beholden.properties.handle)
assert.equal(beholden.properties.handle.value, 'mattly')

changed = 0
trackChange = (val) ->
  assert.equal(val, obj.handle)
  changed += 1

beholden.subscribe('handle', trackChange)
assert.equal(beholden.properties.handle.subscribers.length, 1)

obj.handle = 'lyonheart'
assert.equal(obj.handle, 'lyonheart')

afterChange = ->
  assert.equal(changed, 1)
  console.log('ok')
setTimeout(afterChange, 1)
