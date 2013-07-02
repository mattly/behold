assert = require('assert')
behold = require('../src/index')

obj = {
  one: 1
  two: 2
}

beholden = behold(obj)

beholden.update({
  one: 'one'
  three: 'three'
})

assert.equal(obj.one, 'one')
assert.equal(obj.two, 2)
assert.equal(obj.three, 'three')
assert(beholden.properties.three)

console.log('ok')
