# The macros package

Make atom really hackable.

Fast and dynamic extension of atoms command palette. Adds all methods found in the `.atom/macros.coffee` file as atom commands.

Install the (toolbar module)[https://atom.io/packages/toolbar] for automatic toolbar buttons.

Example of a `macros.coffee`:

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
exec = require('child_process').exec

@runShellCommand = ->
  child = exec 'ls', (error, stdout, stderr) ->
    console.log "stdout: #{stdout}"
    console.log "stderr: #{stderr}"
    if error?
      console.log "exec error: #{error}"

@runShellCommand.icon = 'fa-pied-piper-alt'


@openBrowser = ->
  url = 'https://atom.io'
  if process.platform == 'win32'
    exec "start #{url}"
  else
    exec "open #{url}"

@openBrowser.icon = 'ion-earth'
```

The makro definitions in atom are updated as soon as the file is edited.
