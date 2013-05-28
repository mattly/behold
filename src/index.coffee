class Watcher
  @dependentStack = []
  @dependent = -> @dependentStack[@dependentStack.length - 1]

  constructor: (@name) ->
    @dependents = []
    @subscribers = []
  get: =>
    # prevent circular deps
    # if Watcher.dependentStack.indexOf(this) isnt -1
    if dependent = Watcher.dependent() then @dependents.push(dependent)
    if @dependent
      Watcher.dependentStack.push(this)
      @value = @valueGetter()
      Watcher.dependentStack.pop()
    @value
  set: (newVal) =>
    @value = newVal
    @notify()
    newVal
  subscribe: (fn) ->
    @subscribers.push(fn)
    this
  notify: ->
    process.nextTick(=> @notifySubscribers())
    watcher.notify() for watcher in @dependents
  notifySubscribers: ->
    fn(@value) for fn in @subscribers

stateKey = "_behold"

main = (obj, whitelist) ->
  observables = {}
  properties = Object.getOwnPropertyNames(obj)
  unless whitelist instanceof Array then whitelist = properties
  Object.defineProperty(obj, stateKey, { value: observables })
  for name in Object.keys(obj) when whitelist.indexOf(name) > -1
    main.defineObserver(obj, name, obj[name])
  obj

define = (obj, propName, config) ->
  config.enumerable or= true
  config.configurable or= true
  Object.defineProperty(obj, propName, config)

main.defineObserver = (obj, propName, val) ->
  obj[stateKey][propName] = watch = new Watcher(propName)
  if typeof val is 'function'
    watch.dependent = true
    watch.valueGetter = val.bind(obj)
    watch.get()
    define(obj, propName, {get: watch.get, set: undefined})
  else if typeof val is 'object' then false
  else
    watch.value = val
    define(obj, propName, {get: watch.get, set: watch.set})

main.getObs = (obj, prop) ->
  obj[stateKey][prop]

main.subscribe = (obj, prop, fn, context) ->
  main.getObs(obj, prop).subscribe(fn, context)

main.update = (targetObj, sourceObj) ->
  for own key, value of sourceObj
    if not main.getObs(targetObj, key)
      main[key] = value
      main.defineObserver(targetObj, key, value)
    else targetObj[key] = value

module.exports = main
