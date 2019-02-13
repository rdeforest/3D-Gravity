{spawn} = require 'child_process'

task 'build', 'compile CoffeeScript', (options) ->
  buildProcess = spawn 'coffee', ['-o', 'js', 'src']

task 'build:watch', 're-compile src whenever a file changes', (options) ->
  buildProcess = spawn 'coffee', ['-w', '-o', 'js', 'src']

