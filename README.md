# The atom-macros package

Makes Atom really hackable. Quickly, without writing a package...

Fast and dynamic extension of Atom's command palette. Adds all methods defined by you on `this` in the `.atom/macros.coffee` file as Atom commands: They can be executed using the command palette (`Shift-Cmd-P`) as `Macro: <Your Method Name>`, or from the menu `Packages`>`Macros`>`User-defined macros`.

You can also add a shortcut in your keymaps file:
```coffee
'atom-workspace':
  'ctrl-alt-shift-O': 'macros:openBrowser'
```

## Automatic toolbar generation
Install the [toolbar module](https://atom.io/packages/toolbar) for automatic toolbar buttons.

## Demo

![Demo](https://raw.github.com/pbihler/atom-macros/master/demo.gif)

## Event Handler
Methods named `on...` are not treated as commands, but rather as event handlers, automatically called by the package at the appropriate time.

Currently, two event handlers are specified:
* `onLoad` - Called, when the macros have been loaded, i.e. when Atom started (or you edited the macro definition file)
* `onUnload` - Called, when the macros have been unloaded, i.e. when Atom stopped (or you edited the macro definition file)

## Example

Example of a `macros.coffee` file:

```coffee
@helloConsole = ->
  console.log 'Hello console'
  alert('Watch your console! (open with alt-cmd-i)')

@helloConsole.icon = 'ion-clipboard' # icon from https://atom.io/packages/toolbar#supported-icon-sets
@helloConsole.title = 'Hello Console!'
# icon and title can also be methods returning string



` // If you prefer Javascript, write it between backticks.
this.helloFromJS = function() {
  console.log('Hello from JS');
  alert('Watch your console! (open with alt-cmd-i)');
}
this.helloFromJS.hideIcon = true // don't show this on the toolbar
`

# Every property on "this" which is not a function triggers a separator
@sp1 = "----------------"

# You can also call external commands:

@runShellCommand = ->
  child = exec 'ls', (error, stdout, stderr) ->
    console.log "stdout: #{stdout}"
    console.log "stderr: #{stderr}"
    if error?
      console.log "exec error: #{error}"

@runShellCommand.icon = 'fa-pied-piper-alt'


@openBrowser = ->
  open 'https://atom.io/packages/atom-macros'

  # The toolbar button is updated after the method execution
  # so you can change its properties:
  @title = 'Do it again!'
  @icon = 'ion-thumbsup'

@openBrowser.icon = 'ion-earth'

# Some event handlers are also provided:

@onLoad = ->
  undefined # called, when the macros have been loaded, i.e. when Atom started

@onUnload = ->
  undefined # called, when the macros have been unloaded, i.e. when Atom stopped

```

You find more examples in the [snippets](https://github.com/pbihler/atom-macros/blob/master/SNIPPETS.md) file.

The macro definitions in Atom are updated as soon as the file is changed, i.e. after saving.

### Predefined methods

You can use these shortcuts in your macros:

#### `exec(command, [options], callback)`/`spawn(command, [args], [options])`
From [`child_process`](http://nodejs.org/api/child_process.html).

#### `open(path)`
Calls `open` on Mac and `start` on Windows systems.

#### `getActiveTextEditor()`
Returns atom's active text editor.

#### `getCurrentFilePath()`
Returns the file path of the active pane.
```coffee
@openInDefaultEditor = ->
  open getCurrentFilePath()
```

#### `getCurrentFilePathRelative()`
Returns the file path of the active pane relatively to the current project.

#### `getCurrentProjectPath()`
Returns the current project path
```coffee
@openInExplorer = ->
  open getCurrentProjectPath()
```

#### `dispatchEditorCommand(command)`
Dispatches a command on `'atom-text-editor'` (as defined [here](https://github.com/atom/atom/blob/master/src/text-editor-element.coffee#L239-L345))
```coffee
@lowercaseAll = ->
  dispatchEditorCommand 'core:select-all'
  dispatchEditorCommand 'editor:lower-case'
```

#### `dispatchWorkspaceCommand(command)`
Dispatches a command on `'atom-workspace'`
```coffee
@editMacros = ->
  dispatchWorkspaceCommand 'macros:edit-macros'
  ```

### Predefined variables
* `console`
* `process`
* `atom`
* `subscriptions` - A [CompositeDisposable](https://atom.io/docs/api/latest/CompositeDisposable), which is disposed before the macros are reloaded.
