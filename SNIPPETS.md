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


## "Do not disturb!"

You might not want to be disturbed during work... So why not simply switch a red light on, when working (i.e. Atom is open), and switch it of when you stopped?

Ingredients (as running at my office):
* A red light, e.g. [this one](http://www.amazon.co.uk/Wanted-Message-Battery-Powered-Disturb/dp/B000OBYCAO), (hacked to run on wired power supply)
* A radio controllable socket, e.g.  [these](http://www.amazon.de/Steckdosen-GT-FSI-04a-Funksteckdosen-Quigg-Fernbedienung/dp/B006GDTN4E)
* A RF-Gateway, e.g. [Brematic 433](http://www.amazon.de/Brennenstuhl-Brematic-Single-Gateway-Netzteil/dp/B00EPR87O0)
* A control-script, e.g. [this one](https://github.com/d-a-n/433-codes/blob/master/database.md#quigg)

The code snippet for your `macros.coffee`:
```coffeescript

# Buttons on the toolbar /commands in the menu for manual triggering:

@redLightOn = ->
  exec 'gtfsi04 101100011100 00010001'
@redLightOn.title = 'Ensable DoNotDisturb'
@redLightOn.icon = 'ion-ios7-lightbulb-outline'

@redLightOff = ->
  exec 'gtfsi04 101100011100 00000000'
@redLightOff.title = 'Disable DoNotDisturb'
@redLightOff.icon = 'ion-ios7-lightbulb'

@redLightSeparator = "----------------"

# call on load/on unload:

@onLoad = ->
  @redLightOn()

@onUnload = ->
  @redLightOff()

```
