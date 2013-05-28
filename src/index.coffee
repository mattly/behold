class Watcher
  constructor: (@value) ->
    @subscribers = []
  get: =>
    @value
  set: (newVal) =>
    process.nextTick(@notifySubscribers)
    @value = newVal
  notifySubscribers: =>
    fn() for fn in @subscribers
  subscribe: (fn) ->
    @subscribers.push(fn)
    this

stateKey = "_behold"

main = (obj, whitelist) ->
  observables = {}
  properties = Object.getOwnPropertyNames(obj)
  unless whitelist instanceof Array then whitelist = properties
  Object.defineProperty(obj, stateKey, { value: observables })
  for name in Object.keys(obj) when whitelist.indexOf(name) > -1
    main.defineObserver(obj, name, obj[name])
  obj

main.defineObserver = (obj, propName, val) ->
  switch typeof val
    when 'function' then false
    when 'object' then false
    else
      obj[stateKey][propName] = watch = new Watcher(val)
      Object.defineProperty(obj, propName, {
        enumerable: true
        get: watch.get
        set: watch.set
      })

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
