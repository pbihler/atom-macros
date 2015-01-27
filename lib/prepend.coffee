exec = require('child_process').exec
spawn = require('child_process').spawn

open = (path) ->
  if process.platform == 'win32'
    exec "start \"#{path}\""
  else
    exec "open \"#{path}\""

start = open


getActiveTextEditor = ->
  atom.workspace.getActiveTextEditor()


getCurrentFilePath = ->
  atom.workspace.activePaneItem.getUri()

getCurrentFilePathRelative = ->
  atom.project.relativize(getCurrentFilePath())

getCurrentProjectPath = ->
  atom.project.getPath()

dispatchEditorCommand = (command) ->
  editor = getActiveTextEditor()
  atom.commands.dispatch atom.views.getView(editor), command

dispatchWorkspaceCommand = (command) ->
  atom.commands.dispatch atom.views.getView(atom.workspace), command
