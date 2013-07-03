#! /usr/bin/env coffee
#
# Generate the package.json file for node.js and npm
# Generate the component.json file for component.io
# Generate the bower.json file for Bower
#
github = 'github.com/mattly/behold'
tags = 'observable reactive FRP pubsub publish subscribe'.split(' ')
base =
  name: 'behold'
  description: 'simple frp/pubsub/observers using ECMA5 getters/setters'
  version: '0.2.0'
  author: 'Matthew Lyon <matthew@lyonheart.us>'
  keywords: tags
  tags: tags
  homepage: "https://#{github}"
  repository: "git://#{github}.git"
  bugs: "https://#{github}/issues"
  license: "MIT"
  main: 'index.js'

make = (extend={}) ->
  out = {}
  for obj in [base, extend]
    for key, value of obj
      out[key] = value
  JSON.stringify(out, null, 2)

package_json =
  devDependencies:
    'coffee-script': '1.6.x'
  scripts:
    prepublish: './node_modules/.bin/coffee -c -p src/index.coffee > index.js'
    test: './node_modules/.bin/coffee test/run.coffee'

  engines: { node: '*' }

  component:
    scripts:
      behold: 'index.js'

component_json =
  scripts: ["index.js"]

bower_json =
  ignore: [
    "**/.*"
    "node_modules"
  ]

fs = require('fs')
fs.writeFileSync('package.json', make(package_json))
fs.writeFileSync('component.json', make(component_json))
fs.writeFileSync('bower.json', make(bower_json))

