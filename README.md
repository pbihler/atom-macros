# The atom-macros package

Makes atom really hackable. Quickly, without writing a package...

Fast and dynamic extension of atom's command palette. Adds all methods defined by you on `this` in the `.atom/macros.coffee` file as atom commands: They can be executed using the command palette (`Shift-Cmd-P`) as `Macro: <Your Method Name>`, from the menu `Packages`>`Macros`>`User-defined macros`, or add a shortcut in your keymaps file:
```coffee
'atom-workspace':
  'ctrl-alt-shift-O': 'macros:openBrowser'
```

## Automatic toolbar generation
Install the [toolbar module](https://atom.io/packages/toolbar) for automatic toolbar buttons.

## Example

Example of a `macros.coffee` file:

```coffee
@helloConsole = ->
  console.log 'Hello console'
  alert('Watch your console! (open with alt-cmd-i)')

@helloConsole.icon = 'ion-clipboard' # icon from https://atom.io/packages/toolbar#supported-icon-sets
@helloConsole.title = 'Hello Console!'



` // If you prefer Javascript, write it between backticks.
this.helloFromJS = function() {
  console.log('Hello from JS');
  alert('Watch your console! (open with alt-cmd-i)');
}
this.helloFromJS.hideIcon = true // don't show this on the toolbar
`

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

@openBrowser.icon = 'ion-earth'
```

The macro definitions in atom are updated as soon as the file is changed, i.e. after saving.

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
Dispatches a command on `'atom-text-editor'`
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
