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

  compile: (data, filePath, callback) ->
    sandbox =
      module:
        exports: undefined
      require: require

    try
      if path.extname(filePath) == '.coffeels'
        data = coffee.compile(data, bare: yes)

      dirHash = vm.runInNewContext "module.exports = #{data}", sandbox

      for dir, relPath of dirHash
        absPath = path.resolve(__dirname, '../../..', relPath)
        allFiles = fs.readdirSync absPath
        files = (f for f in allFiles when f[0] isnt '.')
        dirHash[dir] = files

      result =  "module.exports = " + JSON.stringify(dirHash)

    catch err
      error = err
    finally
      callback error, result
