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

defineProperty = (object, name, trigger) ->
  config = { name, value: object[name], dependents: [] }
  if typeof object[name] is 'function'
    config.expression = true
    config.valueGetter = object[name].bind(object)
  Object.defineProperty(object, name, {
    enumerable: true
    configurable: true
    get: -> getValue(config)
    set: (newVal) -> setValue(config, newVal, trigger)
  })
  config

getValue = (config) ->
  deps.addActive(config.dependents)
  config.value

setValue = (config, newVal, trigger, changed) ->
  config.value = newVal
  changed or= [config.name]
  for depConfig in config.dependents when depConfig.expression
    changed.push(depConfig.name)
    setValue(depConfig, deps.track(depConfig), undefined, changed)
  trigger?(changed)
  newVal

class Beholden
  constructor: (@object) ->
    @subscribers = []
    @properties = {}
    @changes = []
    for name in Object.keys(@object)
      @__addProperty(name)
    for name, config of @properties when config.expression
      setValue(config, deps.track(config))
  __addProperty: (name) ->
    notifier = (names) => pushChanges(@changes, names, @__notify)
    @properties[name] = defineProperty(@object, name, notifier)
  __notify: =>
    for sub in @subscribers when @changes.indexOf(sub.property) > -1
      sub.fn(@properties[sub.property].value, @object)
    @changes = []

  subscribe: (property, fn) ->
    if typeof fn isnt 'function' then throw new TypeError("must provide Function")
    if typeof property isnt 'string' then throw new TypeError("must provide String")
    @subscribers.push({property, fn})
    this

  update: (source) ->
    for key, value of source
      if not @properties[key]
        @object[key] = value
        @__addProperty(key)
      else @object[key] = value
    this

pushChanges = (list, names, trigger) ->
  if list.length is 0 then setTimeout(trigger, 0)
  for name in names
    if list.indexOf(name) is -1 then list.push(name)

stateKey = "_behold"

main = (obj) ->
  if obj[stateKey] then return obj[stateKey]
  beholden = new Beholden(obj)
  Object.defineProperty(obj, stateKey, { value: beholden })
  beholden

module.exports = main
