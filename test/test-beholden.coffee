assert = require('assert')
main = require('../src/index')

obj = {
  handle: 'mattly'
  twitter: -> "@#{@handle}"
  reply: -> "#{@twitter}: "
}

beholden = main(obj)

assert.equal(obj._behold, beholden)
assert.ok(beholden.properties.handle)
assert.equal(beholden.properties.handle.value, 'mattly')
assert.ok(beholden.properties.twitter)
assert.equal(beholden.properties.twitter.value, '@mattly')
assert.ok(beholden.properties.reply)
assert.equal(beholden.properties.reply.value, '@mattly: ')

changed = 0
trackChange = (val, updated) ->
  assert.deepEqual(updated, obj)
  changed += 1

beholden.subscribe('handle', trackChange)
beholden.subscribe('twitter', trackChange)
beholden.subscribe('reply', trackChange)
assert.equal(beholden.subscribers.length, 3)

obj.handle = 'lyonheart'
assert.equal(obj.handle, 'lyonheart')
assert.equal(obj.twitter, '@lyonheart')
assert.equal(obj.reply, '@lyonheart: ')

afterChange = ->
  assert.equal(changed, 3)
setTimeout(afterChange, 2)
