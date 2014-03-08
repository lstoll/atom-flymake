FlymakeView = require './flymake-view'

module.exports =
  flymakeView: null

  activate: (state) ->
    @flymakeView = new FlymakeView(state.flymakeViewState)

  deactivate: ->
    @flymakeView.destroy()

  serialize: ->
    flymakeViewState: @flymakeView.serialize()
