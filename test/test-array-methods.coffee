assert = require('assert')
main = require('../src/index')

obj = {
  arr: ['a','b','c']
}

expected = undefined
checkedExpected = 0

checkExpected = (newVal) ->
  checkedExpected += 1
  assert.deepEqual(newVal, expected)

beholden = main(obj)
  .subscribe('arr', checkExpected)

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

assertions.push ->
  expected = ['c','b','a']
  reversed = obj.arr.reverse()
  assert.deepEqual(reversed, expected)
  assert.deepEqual(obj.arr, expected)

assertions.push ->
  expected = ['a','b','c']
  sorted = obj.arr.sort()
  assert.deepEqual(sorted, expected)
  assert.deepEqual(obj.arr, expected)

assertions.push ->
  expected = ['a','d','e','c']
  removed = obj.arr.splice(1,1,'d','e')
  assert.deepEqual(removed, ['b'])
  assert.deepEqual(obj.arr, expected)

assertions.push ->
  expected = ['e','d','c','a']
  sorter = (l,r) -> if l > r then -1 else 1
  sorted = obj.arr.sort(sorter)
  assert.deepEqual(sorted, expected)
  assert.deepEqual(obj.arr, expected)

# make computeds / dependents
# - length
#
# return a computed / dependent ?
# - every
# - filter
# - map
# - some

# make sure all the trigger was called for each op
totalAssertions = assertions.length
assertions.push ->
  assert.equal(totalAssertions, checkedExpected)

# since triggers are pushed to the end of the callstack, we need to push our
# assertions back further
run = ->
  next = assertions.shift()
  if next
    next()
    setTimeout(run, 1)
  else console.log('ok')

setTimeout(run, 1)

