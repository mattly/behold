#! /usr/bin/env coffee
#
# Generate the package.json file
#
github = 'github.com/mattly/behold'
tags = 'pubsub observable reactive FRP'.split(' ')
info =
  name: 'behold'
  description: 'simple pubsub/observers using ECMA5 getters/setters'
  version: '0.1.0'
  author: 'Matthew Lyon <matthew@lyonheart.us>'
  keywords: tags
  tags: tags
  homepage: "https://#{github}"
  repository: "git://#{github}.git"
  bugs: "https://#{github}/issues"
  devDependencies:
    'coffee-script': '1.6.x'
  scripts:
    prepublish: './node_modules/.bin/coffee -c -b -p src/index.coffee > index.js'
    test: './node_modules/.bin/coffee test/run.coffee'

  main: 'index.js'
  engines: { node: '*' }

require('fs')
  .writeFileSync('package.json', JSON.stringify(info, null, 2))
