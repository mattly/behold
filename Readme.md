# Behold

Simple PubSub / Observers / Functional Reactive Programming for object
properties using ECMA5 getters/setters.

Still *very much* a work in progress.

``` javascript
var obj = {
  one: 1,
  two: 2,
  arr: [1,2,3]
};

var beholden = behold(obj)
  .subscribe('arr', function(val){ console.log('arr', val.length); })
  .subscribe('one', function(val){ console.log('one', val); })
  .subscribe('two', function(val){ console.log('two', val); })
  .update({one: 'One', two: 'Two'});

console.log(obj.one, obj.two)
// 'One', 'Two'

var beholder = behold(function(){ return obj.one + obj.two })
  .subscribe(function(val){ console.log('onetwo', val); });

obj.arr.push(4);
obj.one = 'one'

// arr 4
// one 'one'
// two 'Two'
// onetwo 'oneTwo'
```

# Public API

## behold(thing)

- **thing** (required): Object, or Function that is the target. See separate
  descriptions below.

## behold(object)

Tracks values on the object. Returns a Beholden, described below.

### How different value types are tracked

- Primitives (Boolean, String, Number, etc) are given regular getters/setters.
- Arrays' mutator methods (push, pop, shift, unshift, reverse, sort, splice)
  are enhanced such that they will trigger subscription updates.
- Objects are not currently recursed into.
- Functions are ignored. If you want a 'reactive expression' that tracks the
  value of beholden values that a function touches, you can call behold(fn) and
  it will return a 'Beholder' (described below) whose 'value' property will
  always reflect the current result of the expression *fn*.

## behold(func)

Tracks an expression for the function given. Returns a Beholder, described
below.

## Beholden

A Beholden encapsulates an object whose non-function properties are being
observed and are subscribable.

### beholden.subscribe(propertyName, fn)

- **propertyName** (required): String, name of the property to listen to
- **fn** (required): Function called with (newValue) arguments when value
  changes.

Subscribed functions are called after the callstack clears.

Returns the Beholden.

### beholden.update(updateObj)

- **updateObj** (required): Object, whose properties will be transfered over to
  the target object.

If the target object lacks values from the update Object, they will be created
as observable properties.

Returns the Beholden.

## Beholder

A Beholder watches an expression for observable values accessed from objects
tracked via behold(obj) and provides a way to subscribe to the changed result.

### beholder.subscribe(fn)

- **fn** (required): Function called with (newValue) argument when the values
  tracked by the original tracked expression change.

Subscribed functions are called after the callstack clears.

Returns the Beholder.

## Issues / Problems / Roadmap

* Requires ECMA5, so it'll work in IE9+ but not older.
* Will transform all enumerable properties on the object, ownProperty or not.
* Array#length is not subscribable.
* Roadmap: will recurse into object values on the target object

## Acknowledgements

Inspired by working with [Knockout][], but realizing I wanted something much
smaller in scope and functionality, and without all the function calls.

[Knockout]: http://knockoutjs.com/
