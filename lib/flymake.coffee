module.exports =
  flymakeView: null

  # Atom stuff
  activate: (state) ->
    @registerEvents()


  deactivate: ->


  serialize: ->


  # Our stuff
  registerEvents: ->
    atom.workspace.eachEditor (editor) =>
      editor.on 'saved contents-modified', =>
        console.log "Event fired"
        runner = @debounce 5000, =>
          console.log "In debounce"
          @make(editor)
        runner()

  make: ->
    console.log "I would be making"


  # Utils
  debounce: (wait, callback) ->
    timeoutId = null
    ->
      clearTimeout timeoutId if timeoutId
      timeoutId = setTimeout callback, wait
      return
