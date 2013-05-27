assert = require('assert')
main = require('../src/index')

obj = {
  handle:'mattly'
}

main(obj)

assert.ok(obj._behold)
assert.ok(obj._behold.handle)
assert.equal(obj._behold.handle.value, 'mattly')

changed = 0
trackChange = ->
  changed += 1

main.subscribe(obj, 'handle', trackChange)
assert.equal(obj._behold.handle.subscribers.length, 1)

obj.handle = 'lyonheart'
assert.equal(obj.handle, 'lyonheart')

afterChange = ->
  assert.equal(changed, 1)
setTimeout(afterChange, 1)
