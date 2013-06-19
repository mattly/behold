# Behold

Simple PubSub / Observers for object properties using ECMA5 getters/setters.
Still *very much* a work in progress.

``` javascript
var obj = {
  one: 1,
  two: 2,
  onetwo: function(){ return this.one + this.two; }
};
behold(obj);
beholden.subscribe('onetwo', function(val) { console.log(val); })
obj.one = 'one';
// one2
```

## Public API

### behold(obj)

- **obj** (required): Object, whose properties that will be observed.

Returns a Beholden, described below.

#### How different value types are tracked

- Primitives (Boolean, String, Number, etc) are given regular getters/setters.
- Arrays are treated like objects. In the future their push/pop/slice etc
  methods will get observable-triggering super-powers, see Roadmap below.
- Objects are not currently recursed into.
- Functions become "reactive expressions", where their result is available on
  the target object as if it were a normal value. It will update whenever any
  observed value it depends on is updated, and can be subscribed to like any
  other observable value.

### beholden.subscribe(propertyName, fn)

- **propertyName** (required): String, name of the property to listen to
- **fn** (required): Function, will be called with new value of property when it
  changes.

Returns the Beholden.

### beholden.update(updateObj)

- **updateObj** (required): Object, whose properties will be transfered over to
  the target object.

If the target object lacks values from the update Object, they will be created
as observable properties.

Returns the Beholden.

## Issues / Problems / Roadmap

* Requires ECMA5, so it'll work in IE9+ but not older.
* Will transform all enumerable properties.
* **ROADMAP**: arrays will gain push/pop/slice/shift accessors:

    ``` javascript
    var o = {arr: [1,2,3]};
    behold(o).subscribe(o, 'arr', function(){ console.log(o.arr.length) });
    o.arr.push(4);
    // 4
    ```

## Acknowledgements

Inspired by working with [Knockout][], but realizing I wanted something much
smaller in scope / functionality, and without the function calls.

[Knockout]: http://knockoutjs.com/
