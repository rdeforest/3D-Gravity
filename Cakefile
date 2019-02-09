fs     = require 'fs'
path   = require 'path'

coffee = require 'coffeescript/src/coffeescript/command'

task 'build', 'compile CoffeeScript', (options) ->
  srcDir = path.resolve __dirname, 'src'

  for stat from fs.readdirSync srcDir, withFileTypes: true
    continue unless stat.isFile() and stat.name.match /coffee$/

    coffee ...


