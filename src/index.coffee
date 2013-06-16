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

class Watcher
  @dependentStack = []
  @dependent = -> @dependentStack[@dependentStack.length - 1]

  constructor: (@name) ->
    @dependents = []
    @subscribers = []
  get: =>
    Eye.addActiveDependent(@dependents)
    if @dependent then @value = Eye.track(this, @valueGetter)
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
  valuesToInit = []
  if typeof val is 'function'
    watch.dependent = true
    watch.valueGetter = val.bind(obj)
    valuesToInit.push(watch)
    define(obj, propName, {get: watch.get, set: undefined})
  else if typeof val is 'object' then false
  else
    watch.value = val
    define(obj, propName, {get: watch.get, set: watch.set})
  watch.get() for watch in valuesToInit
  obj

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
