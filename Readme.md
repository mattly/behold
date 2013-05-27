# Behold

Simple PubSub / Observers for object properties using ECMA5 getters/setters.
Still *very much* a work in progress.

``` javascript
obj = { one: 1, two: 2 };
behold(obj);
behold.subscribe(obj, 'one', function(){ console.log('obj.one:',obj.one); });
obj.one = 'one';
// obj.one:one
```

## Public API

### behold(obj, [whitelist])

- **obj** (required): an object whose ownProperties that will be watched.
- **whitelist** (optional): an array of strings naming the only properties
  on obj we wish to track.

Returns the object provided.

### behold.subscribe(obj, propertyName, fn)

Call function **fn** when the property **propertyName** on object **obj**
changes.

## Issues / Problems / Roadmap

* Requires ECMA5, so it'll work in IE9+ but not older.
* Watches only ownProperty values that are not functions/objects/arrays:
  - ownProperty functions will become expressions:
      o = {handle:'mattly', twitter:function(){ return "@"+this.handle } }
      behold(o)
      o.handle = 'matthewlyon'
      o.twitter // @matthewlyon
  - arrays will gain push/pop/slice/shift accessors:
      o = behold({arr: [1,2,3]})
      behold.subscribe(o, 'arr', function(){ console.log(o.arr.length) })
      o.arr.push(4)
      // 4
  - objects will track the setting of, but not their own properties.
