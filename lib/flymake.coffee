Maker = require('./maker')

module.exports =
  flymakeView: null
  maker: null

  # Atom stuff
  activate: (state) ->
    @maker = new Maker()
    @registerEvents()


  deactivate: ->


  serialize: ->


  # Our stuff
  registerEvents: ->
    atom.workspace.eachEditor (editor) =>
      editor.on 'saved contents-modified', =>
        console.log "Event fired"
        runner = @debounce 1, => # debouce 5000?
          console.log "In debounce"
          @maker.make editor.getTitle(), editor.getText(), @editorGrammar(editor), (err, matches)=>
            if err
              console.log "Error occured, #{err}"
            else
              @handleMatches editor, matches
        runner()

  handleMatches: (editor, matches) =>
    console.log matches

  editorGrammar: (editor) ->
    grammar = editor.getGrammar()
    if grammar == atom.syntax.nullGrammar then "Plain Text" else grammar.name

  # Utils
  debounce: (wait, callback) ->
    timeoutId = null
    ->
      clearTimeout timeoutId if timeoutId
      timeoutId = setTimeout callback, wait
      return
