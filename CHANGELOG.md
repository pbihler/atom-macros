## 0.5.1 - Update pathwatcher reference

## 0.5.0 - Allowed title/icon to be functions
* and auto-update of toolbar button after method call

## 0.4.0 - Added event handlers
* onLoad / onUnload
* fixed double loading on change of `macros.coffee`

## 0.3.2 - Updated pathwatcher module
* Compatibility with io.js / Atom.io 0.177

## 0.3.0 - Separators added

## 0.2.2 - Description improved

## 0.2.1 - Bugfix in sample

## 0.2.0 - Predefined methods
* Macros are added to the menu
* Now several methods are predefined as shortcuts:

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

* Predefined variables in macro scope

## 0.1.0 - First Release
* Commands
* Toolbars
