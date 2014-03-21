vm = require 'vm'
coffee = require 'coffee-script'
path = require 'path'
fs = require 'fs'

module.exports = class lsCompiler
  brunchPlugin: yes
  type: 'javascript'
  pattern: /\.(js|coffee)ls$/

  constructor: (@config) ->
    null

  compile: (data, path, callback) ->
    sandbox =
      module:
        exports: undefined
      require: require

    try
      if path.extname(path) == '.coffeels'
        data = coffee.compile(data, bare: yes)

      dirHash = vm.runInNewContext "module.exports = #{data}", sandbox

      for name, relPath of dirHash
        absPath = path.resolve(__dirname, '..', relPath)
        do (key) -> fs.readdir absPath, (err, files) ->
          throw err if err
          dirHash[key] = files

      result =  "module.exports = " + JSON.stringify(dirHash)

    catch err
      error = err
    finally
      callback error, result
