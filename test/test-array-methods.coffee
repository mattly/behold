assert = require('assert')
main = require('../src/index')

obj = {
  arr: ['a','b','c']
}

expected = undefined
changed = 0

checkChange = (newVal) ->
  changed += 1
  assert.deepEqual(newVal, expected)

beholden = main(obj)
  .subscribe('arr', checkChange)

assertions = []

assertions.push ->
  expected = ['a','b','c','d']
  newLen = obj.arr.push('d')
  assert.equal(newLen, 4)
  assert.equal(obj.arr.length, 4)
  assert.deepEqual(obj.arr, expected)

assertions.push ->
  expected = ['a','b','c']
  popped = obj.arr.pop()
  assert.equal(popped, 'd')
  assert.equal(obj.arr.length, 3)
  assert.deepEqual(obj.arr, expected)

assertions.push ->
  expected = ['_','a','b','c']
  newLen = obj.arr.unshift('_')
  assert.equal(newLen, 4)
  assert.equal(obj.arr.length, 4)
  assert.deepEqual(obj.arr, expected)

assertions.push ->
  expected = ['a','b','c']
  shifted = obj.arr.shift()
  assert.equal(shifted, '_')
  assert.equal(obj.arr.length, 3)
  assert.deepEqual(obj.arr, expected)

# make sure all the trigger was called for each op
totalAssertions = assertions.length
assertions.push ->
  assert.equal(totalAssertions, changed)

# since triggers are pushed to the end of the callstack, we need to push our
# assertions back further
run = ->
  next = assertions.shift()
  if next
    next()
    setTimeout(run, 1)
  else console.log('ok')

setTimeout(run, 1)

