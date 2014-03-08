{View} = require 'atom'

module.exports =
class FlymakeView extends View
  @content: ->
    @div class: 'flymake overlay from-top', =>
      @div "The Flymake package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "flymake:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "FlymakeView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
