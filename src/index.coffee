deps =
  stack: []
  push: (arr) ->
    active = @stack[@stack.length - 1]
    if active and arr.indexOf(active) is -1 then arr.push(active)
  track: (property, getter) ->
    # throw if stack inclues watcher, prevent circular deps
    # if @stack.indexOf(watcher) isnt -1 then ...
    @stack.push(property)
    val = getter()
    @stack.pop(property)
    val

defineProperty = (object, name, prop) ->
  if typeof object[name] is 'function'
    prop.dependent = true
    prop.valueGetter = object[name].bind(object)
    prop.update()
  Object.defineProperty(object, name, {
    enumerable: true
    configurable: true
    get: prop.get
    set: prop.set
  })
  prop

class Beholden
  constructor: (@object) ->
    @dependents = []
    @subscribers = []
    @properties = {}
    @changes = new Beholden.Changes(@__notify.bind(this))
    for name in Object.keys(@object)
      @properties[name] = new Beholden.Property(@object[name], @__notifier(name))
      defineProperty(@object, name, @properties[name])
  __notifier: (name) ->
    => @changes.push(name)
  __notify: ->
    changed = @changes.harvest()
    for sub in @subscribers when changed.indexOf(sub.property) > -1
      sub.fn(@properties[sub.property].value)

  subscribe: (property, fn) ->
    if typeof fn isnt 'function' then throw new TypeError("must provide Function")
    if typeof property isnt 'string' then throw new TypeError("must provide String")
    @subscribers.push({property, fn})
    this

  update: (source) ->
    for key, value of source
      if not @properties[key]
        @properties[key] = new Beholden.Property(value, @__notifier(key))
        defineProperty(@object, key, @properties[key])
      else @object[key] = value
    this

class Beholden.Property
  constructor: (@value, @bang) ->
    @dependents = []
  get: =>
    deps.push(@dependents)
    @value
  set: (newVal) =>
    @value = newVal
    dep.update() for dep in @dependents
    @bang()
    newVal
  update: ->
    if @dependent then @set(deps.track(this, @valueGetter))

class Beholden.Changes
  constructor: (@trigger) ->
    @list = []
    @tipped = false
  push: (name) ->
    if @list.indexOf(name) is -1 then @list.push(name)
    if not @tipped
      @tipped = true
      setTimeout(@trigger, 0)
  harvest: ->
    @tipped = false
    ret = (name for name in @list)
    @list = []
    ret

stateKey = "_behold"

main = (obj) ->
  if obj[stateKey] then return obj[stateKey]
  beholden = new Beholden(obj)
  Object.defineProperty(obj, stateKey, { value: beholden })
  beholden

module.exports = main
