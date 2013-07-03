
deps =
  stack: []
  addActive: (arr) ->
    active = @stack[@stack.length - 1]
    if active and arr.indexOf(active) is -1 then arr.push(active)
  track: (config) ->
    # throw if stack inclues watcher, prevent circular deps
    # if @stack.indexOf(watcher) isnt -1 then ...
    @stack.push(config)
    val = config.valueGetter()
    @stack.pop(config)
    val

class Beholdable
  constructor: ->
    @dependents = []
    @subscribers = []
    @__triggered = false
  __trigger: ->
    if @__triggered then return
    @__triggered = true
    setTimeout(@__fire, 0)
    dep.__trigger() for dep in @dependents
  __fire: =>
    @__triggered = false
    sub(@value) for sub in @subscribers
  subscribe: (fn) ->
    if typeof fn isnt 'function' then throw new TypeError("must provide Function")
    @subscribers.push(fn)
    this

defineProperty = (object, name) ->
  target = object[name]
  config = new Beholdable()
  config.value = target
  if target instanceof Array
    'push pop unshift shift reverse sort splice'.split(' ').forEach (prop) ->
      Object.defineProperty(target, prop, {
        value: (args...) ->
          config.__trigger()
          Array::[prop].call(target, args...)
      })
  Object.defineProperty(object, name, {
    enumerable: true
    configurable: true
    get: -> getValue(config)
    set: (newVal) -> setValue(config, newVal)
  })
  config

getValue = (config) ->
  deps.addActive(config.dependents)
  config.value

setValue = (config, newVal) ->
  config.value = newVal
  for depConfig in config.dependents
    setValue(depConfig, deps.track(depConfig))
  config.__trigger()
  newVal

class Beholden
  constructor: (@object) ->
    @properties = {}
    for name in Object.keys(@object) when typeof @object[name] isnt 'function'
      @__addProperty(name)
    for name, config of @properties when config.expression
      setValue(config, deps.track(config))
  __addProperty: (name) ->
    @properties[name] = defineProperty(@object, name)

  subscribe: (name, fn) ->
    if typeof fn isnt 'function' then throw new TypeError("must provide Function")
    if typeof name isnt 'string' then throw new TypeError("must provide String")
    if beholdable = @properties[name] then beholdable.subscribe(fn)
    this

  update: (source) ->
    for key, value of source
      if not @properties[key]
        @object[key] = value
        @__addProperty(key)
      else @object[key] = value
    this

class Beholder extends Beholdable
  constructor: (@valueGetter) ->
    @expression = true
    super()
    @value = deps.track(this)

stateKey = "_behold"

main = (thing) ->
  if thing[stateKey] then return thing[stateKey]
  if thing instanceof Function
    beholden = new Beholder(thing)
  else if thing instanceof Object
    beholden = new Beholden(thing)
  Object.defineProperty(thing, stateKey, { value: beholden })
  beholden

if typeof this is 'object' and typeof module is 'object'
  module.exports = main
else if typeof define is 'function' and define.amd
  define(main)
else
  this.behold = main
