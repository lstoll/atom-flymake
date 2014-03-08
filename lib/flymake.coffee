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

  handleMatches: (editor, matches) ->
    editorView = atom.workspaceView.getActiveView()

    # Clean out UI stuff
    editorView.resetDisplay()
    editorView.gutter.find('.flymake-line-number').removeClass('flymake-line-number')
    atom.workspaceView.statusBar.find('#flymake-statusbar').remove();

    # Do it
    boundDisplayError = (match) =>
      @displayError(editor, match)

    if matches[0]
      @updateStatusbar matches[0]

    boundDisplayError match for match in matches



  displayError: (editor, match) ->
    message = match['message']
    line = match['line']
    row = line - 1

    editorView = atom.workspaceView.getActiveView()

    gutter = editorView.gutter
    bufferRange = editor.bufferRangeForBufferRow(row)
    screenRange = editor.screenRangeForBufferRange(bufferRange)
    lineEl = editorView.lineElementForScreenRow(screenRange.start.row)
    lineEl.addClass('flymake-line')

    gutterRow = gutter.find(gutter.getLineNumberElement(row))
    gutterRow.attr('title', message)
    gutterRow.addClass('flymake-line-number')

  # Will display the passed match in the status bar
  updateStatusbar: (match) ->
    atom.workspaceView.statusBar.appendLeft('<span id="flymake-statusbar" class="inline-block">Flymake ' + match.line + ': ' + match.message + '</span>')

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
