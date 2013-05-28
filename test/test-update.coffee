assert = require('assert')
behold = require('../src/index')

obj = {
  one: 1
  two: 2
}

behold(obj)

behold.update(obj, {
  one: 'one'
  three: 'three'
})

assert.equal(obj.one, 'one')
assert.equal(obj.two, 2)
assert.equal(obj.three, 'three')
assert(obj._behold.three)
