# Behold

Simple PubSub / Observers for object properties using ECMA5 getters/setters.
Still *very much* a work in progress.

``` javascript
var obj = {
  one: 1,
  two: 2,
  onetwo: function(){ return this.one + this.two; }
  arr: [1,2,3]
};
var beholden = behold(obj);
beholden
  .subscribe('onetwo', function(val, obj) { console.log('onetwo', val); })
  .subscribe('arr', function(val, obj){ console.log('arr', val.length); });
obj.one = 'one';
obj.arr.push(4);
// onetwo one2
// arr 4
```

## Public API

### behold(obj)

- **obj** (required): Object, whose properties that will be observed.

Returns a Beholden, described below. Multiple calls with the same object will
return the same beholden (stored on the object at "_behold"). This statement:

``` javascript
beholden = behold(obj);
beholden.update({three: 3});
```

is equivalent to:

``` javascript
behold(obj).update({three: 3});
```

#### How different value types are tracked

- Primitives (Boolean, String, Number, etc) are given regular getters/setters.
- Arrays' mutator methods (push, pop, shift, unshift, reverse, sort, splice)
  are enhanced such that they will trigger subscription updates.
- Functions become "reactive expressions", where their result is available on
  the target object as if it were a normal value. It will update whenever any
  observed value it depends on is updated, and can be subscribed to like any
  other observable value.
- Objects are not currently recursed into.

### beholden.subscribe(propertyName, fn)

- **propertyName** (required): String, name of the property to listen to
- **fn** (required): Function called with (newValue, object) arguments when
  value changes.

Returns the Beholden.

### beholden.update(updateObj)

- **updateObj** (required): Object, whose properties will be transfered over to
  the target object.

If the target object lacks values from the update Object, they will be created
as observable properties.

Returns the Beholden.

## Issues / Problems / Roadmap

* Requires ECMA5, so it'll work in IE9+ but not older.
* Will transform all enumerable properties on the object, ownProperty or not.
* Array#length is not subscribable.

## Acknowledgements

Inspired by working with [Knockout][], but realizing I wanted something much
smaller in scope and functionality, and without the function calls.

[Knockout]: http://knockoutjs.com/
