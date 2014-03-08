os = require('os')
fs = require('fs')
{exec} = require('child_process')


module.exports =
  class Maker
    # Functionality

    # Takes a string buffer, and returns a list of errors in format
    # [{line: 26, message: "Syntax Error"}]
    make: (filename, contents, grammar, callback)->
      langMap = @makerMap[grammar]
      if !langMap
        callback('ENOMAP')
      else
        tmpFile = @writeTempFile filename, contents
        @doMake tmpFile, langMap, callback

    doMake: (tmpFile, langMap, callback)->
      cmd = langMap['command']
      errReturnCode = langMap['errReturnCode'] || 0
      cmd += " " + tmpFile
      child = exec cmd, (error, stdout, stderr) =>
        if error && error.code != errReturnCode
          console.log('flymake exec error: ' + error)
        else
          output = stdout.toString() + stderr.toString()
          lines = output.split("\n")

          boundProcessLine = (line)=>
            @processLine line, langMap['matcher']

          processed = (boundProcessLine line for line in lines)
          # clear out empty stuff
          processed = (i for i in processed when i isnt undefined)
          @deleteFile tmpFile
          callback(null, processed)


    processLine: (line, matcher) ->
      match_line = matcher['line']
      match_msg = matcher['msg']
      match_regex = matcher['regex']

      match = line.match match_regex
      if match
        {'line': match[match_line], 'message': match[match_msg]}


    # Write the file contents out to a temp file
    # Returns the filename
    writeTempFile: (filename, contents)->
      tmpFileName = os.tmpdir() + "atomflymake_" + (+ new Date()) + '_' + filename
      fs.writeFile tmpFileName, contents, (err) ->
        throw err if err
      return tmpFileName

    deleteFile: (filename)->
      fs.unlink filename, (err)->
        console.log(err) if err


    # Language Map
    makerMap: {
      'Ruby': {
        'command'  : "ruby -c"
        'matcher'  : {'regex': /^(.*):([0-9]+): (.*)$/, 'file': 1, 'line': 2, 'msg': 3}
        # If we return a non 0 status
        'errReturnCode': 1
      }
    }
