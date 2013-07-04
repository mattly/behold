assert = require('assert')
main = require('../src/index')

objA = { a: 1 }
objB = { b: 2 }

ran = 0
add = -> objA.a + objB.b

main(objA)
main(objB)

verifyUpdate = (val, obj) ->
  ran += 1
  assert.equal(val, add())

main(add).subscribe(verifyUpdate)

puts = (msg) -> console.log(msg)

assertions = []
assertions.push -> objA.a = 4
assertions.push -> objB.b = 5
assertions.push ->
  objA.a = 10
  objB.b = 4
  objA.a = 12

total = assertions.length
assertions.push -> assert.equal(ran, total)

require('./chain')(assertions)
