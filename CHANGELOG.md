## 0.2.0 - Bugfix in sample

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
