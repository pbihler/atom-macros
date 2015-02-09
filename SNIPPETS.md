# Snippets for your `macros.coffee`

## A toolbar button for the command palette

The code snippet for your `macros.coffee`:
```coffeescript
@commandPalette = ->
  dispatchWorkspaceCommand 'command-palette:toggle'
@commandPalette.icon = 'three-bars'

@cpSeparator = "----------------"
```

## Toolbar buttons for mocha testing
Requires the [mocha-test-runner package](https://atom.io/packages/mocha-test-runner).


The code snippet for your `macros.coffee`:
```coffeescript
@runTest = ->
  dispatchWorkspaceCommand  'mocha-test-runner:run'
@runTest.icon = 'ion-checkmark'


@runLastTest  = ->
  dispatchWorkspaceCommand  'mocha-test-runner:run-previous'
@runLastTest.icon = 'ion-checkmark-circled'

@debugTest = ->
  dispatchWorkspaceCommand  'mocha-test-runner:debug'
@debugTest.icon = 'bug'

@debugLastTest = ->
  dispatchWorkspaceCommand  'mocha-test-runner:debug-previous'
@debugLastTest.icon = 'ion-bug'

@testSep = "----------------"
```

## Open file from path on clipboard

Copy your filename (e.g. from your stacktrace) to the clipboard. Run this command:

```coffeescript
openExtendedPath = (extendedPath) ->
  parts = /^([^:]+)(?::(\d+)(?::(\d+))?)?$/.exec(extendedPath)
  return unless parts?

  [filename,row,col] = parts.slice(1)
  return unless filename?

  fs = require 'fs'
  unless fs.existsSync(filename)
    alert "File not found: #{filename}"
    return

  atom.workspace.open(filename)
  .then ->

    return unless row?
    col ?= 0

    {Point} = require 'atom'
    position = new Point(--row, --col)
    getActiveTextEditor().scrollToBufferPosition(position, center:true)
    getActiveTextEditor().setCursorBufferPosition(position)

@openFileFromPathInClipboard = ->
  extendedPath = atom.clipboard.read()
  openExtendedPath(extendedPath)
@openFileFromPathInClipboard.icon = 'fa-file'
```

## Main toolbar

Add Icons to the toolbar for the main Atom, commands, like [toolbar-main](https://atom.io/packages/toolbar-main) does:
```coffeescript
@tbMainSep0 = '-'

@newFile = -> dispatchWorkspaceCommand 'application:new-file'
@newFile.icon = 'ion-document'
@newFile.title = 'New File'

@openFile = -> dispatchWorkspaceCommand 'application:open-file'
@openFile.icon = 'ion-folder'
@openFile.title = 'Open...'

@saveFile = -> dispatchWorkspaceCommand 'core:save'
@saveFile.icon = 'ion-archive'
@saveFile.title = 'Save'

@tbMainSep1 = '-'

@findInBuffer = -> dispatchWorkspaceCommand 'find-and-replace:show'
@findInBuffer.icon = 'ion-search'
@findInBuffer.title = 'Find in Buffer'

@replaceInBuffer = -> dispatchWorkspaceCommand 'find-and-replace:show-replace'
@replaceInBuffer.icon = 'ion-shuffle'
@replaceInBuffer.title = 'Replace in Buffer'

@tbMainSep2 = '-'

@toggleCommandPalette = -> dispatchWorkspaceCommand 'command-palette:toggle'
@toggleCommandPalette.icon = 'ion-navicon-round'
@toggleCommandPalette.title = 'Toggle Command Palette'

@openSettings = -> dispatchWorkspaceCommand 'settings-view:open'
@openSettings.icon = 'ion-gear-a'
@openSettings.title = 'Open Settings View'

if atom.inDevMode()
  @tbMainSep3 = '-'

  @reloadWindow = -> dispatchWorkspaceCommand 'window:reload'
  @reloadWindow.icon = 'ion-refresh'
  @reloadWindow.title = 'Reload Window'

  @toggleDeveloperTools = -> require('remote').getCurrentWindow().toggleDevTools()
  @toggleDeveloperTools.icon = 'terminal'
  @toggleDeveloperTools.title = 'Toggle Developer Tools'
```



## "Do not disturb!"

You might not want to be disturbed during work... So why not simply switch a red light on, when working (i.e. Atom is open), and switch it of when you stopped?

Ingredients (as running at my office):
* A red light, e.g. [this one](http://www.amazon.co.uk/Wanted-Message-Battery-Powered-Disturb/dp/B000OBYCAO), (hacked to run on wired power supply)
* A radio controllable socket, e.g.  [these](http://www.amazon.de/Steckdosen-GT-FSI-04a-Funksteckdosen-Quigg-Fernbedienung/dp/B006GDTN4E)
* A RF-Gateway, e.g. [Brematic 433](http://www.amazon.de/Brennenstuhl-Brematic-Single-Gateway-Netzteil/dp/B00EPR87O0)
* A control-script, e.g. [this one](https://github.com/d-a-n/433-codes/blob/master/database.md#quigg)

The code snippet for your `macros.coffee`:
```coffeescript

atom.redLightOn = false # remember state globally

# the control methods

switchRedLightOn = ->
  exec 'gtfsi04 101100111000 00010001'
  atom.redLightOn = true

switchRedLightOff = ->
  exec 'gtfsi04 101100111000 00000000'
  atom.redLightOn = false

# Button on the toolbar / command in the menu for manual triggering:

@toggleRedLight = ->
  if atom.redLightOn then switchRedLightOff() else switchRedLightOn()

@toggleRedLight.title =  ->
  if atom.redLightOn then 'Switch Red Light off' else 'Switch Red Light on'

@toggleRedLight.icon =  ->
  if atom.redLightOn then 'ion-ios7-lightbulb-outline' else 'ion-ios7-lightbulb'

# call on load/on unload:

@onLoad = =>
  switchRedLightOn()
  @toggleRedLight.updateButton()

@onUnload = ->
  switchRedLightOff()


```
