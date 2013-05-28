assert = require('assert')
main = require('../src/index')

obj = {
  handle:'mattly'
  twitter: -> "@#{@handle}"
}

main(obj)

assert.ok(obj._behold)
assert.ok(obj._behold.handle)
assert.equal(obj._behold.handle.value, 'mattly')
assert.ok(obj._behold.twitter)

changed = 0
trackChange = (val) ->
  changed += 1

main.subscribe(obj, 'handle', trackChange)
main.subscribe(obj, 'twitter', trackChange)
assert.equal(obj._behold.handle.subscribers.length, 1)
assert.equal(obj._behold.twitter.subscribers.length, 1)

obj.handle = 'lyonheart'
assert.equal(obj.handle, 'lyonheart')
assert.equal(obj.twitter, '@lyonheart')

afterChange = ->
  assert.equal(changed, 2)
setTimeout(afterChange, 1)
