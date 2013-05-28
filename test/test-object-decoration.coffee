assert = require('assert')
main = require('../src/index')

class User
  constructor: (props={}) ->
    for own key, value of props
      @[key] = value
    Object.defineProperty(this, 'id', {
      configurable: true
      enumerable: false
      value: '42'
    })
  twitter: -> "@#{@handle}"

inst = new User({
  handle:'mattly',
  first: 'Matthew',
  last: 'Lyon',
  name: -> @first + ' ' + @last
})
inst = main(inst)

assert.ok(inst._behold)

handle = Object.getOwnPropertyDescriptor(inst, 'handle')
assert.ok(handle.get)
assert.ok(handle.set)
assert.equal(handle.enumerable, true)

assert.equal(inst.name, "#{inst.first} #{inst.last}")
name = Object.getOwnPropertyDescriptor(inst, 'name')
assert.ok(name.get)
assert.equal(name.set, undefined)
assert.equal(handle.enumerable, true)

assert.equal(inst.twitter(), "@#{inst.handle}")
twitter = Object.getOwnPropertyDescriptor(inst, 'twitter')
assert.equal(twitter, undefined)

secret = Object.getOwnPropertyDescriptor(inst, 'id')
assert.equal(secret.get, undefined)
assert.equal(secret.set, undefined)

obj = {one: 1, two: 2}
main(obj, ['one'])

one = Object.getOwnPropertyDescriptor(obj, 'one')
assert.ok(one.get)
assert.ok(one.set)
assert.equal(one.enumerable, true)

two = Object.getOwnPropertyDescriptor(obj, 'two')
assert.equal(two.get, undefined)
assert.equal(two.set, undefined)
