Eye =
  stack: []
  active: -> @stack[@stack.length - 1]
  addActiveDependent: (arr) ->
    active = @active()
    if active and arr.indexOf(active) is -1 then arr.push(active)
  track: (watcher, getter) ->
    # throw if stack inclues watcher, prevent circular deps
    # if @stack.indexOf(watcher) isnt -1 then ...
    @stack.push(watcher)
    val = getter()
    @stack.pop(watcher)
    val

define = (obj, propName, config) ->
  config.enumerable or= true
  config.configurable or= true
  Object.defineProperty(obj, propName, config)

class Beholden
  constructor: (@object) ->
    @dependents = []
    @subscribers = []
    @properties = {}
    @changes = new Beholden.Changes(@__notify.bind(this))
    for name in Object.keys(@object)
      prop = @properties[name] = new Beholden.Property(@object[name], @__notifier(name))
      if typeof @object[name] is 'function'
        prop.dependent = true
        prop.valueGetter = @object[name].bind(@object)
        prop.update()
      define(@object, name, { get: prop.get, set: prop.set })
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

class Beholden.Property
  constructor: (@value, @bang) ->
    @dependents = []
  get: =>
    Eye.addActiveDependent(@dependents)
    @value
  set: (newVal) =>
    @value = newVal
    dep.update() for dep in @dependents
    @bang()
    newVal
  update: ->
    if @dependent then @set(Eye.track(this, @valueGetter))

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

main.update = (targetObj, sourceObj) ->
  for own key, value of sourceObj
    if not main.getObserver(targetObj, key)
      main[key] = value
      main.defineObserver(targetObj, key, value)
    else targetObj[key] = value

module.exports = main
