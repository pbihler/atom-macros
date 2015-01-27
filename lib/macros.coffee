# License: MIT

{CompositeDisposable} = require 'atom'
PATH = require 'path'
FS = require 'fs'
COFFEESCRIPT = require 'coffee-script'
EVAL = require 'eval'
PathWatcher = require 'pathwatcher'

MACROS_FILE = 'macros.coffee'

module.exports = Macros =
  subscriptions: null
  makroSubscriptions: null
  macros: {}
  toolbar: null

  activate: (state) ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'macros:open-macros': => @openMacros()
    @subscriptions.add atom.commands.add 'atom-workspace', 'macros:reload-macros': => @updateMacrosWithUi()

    @updateMacros()
    macrosPath = @_getMacrosPath()

    PathWatcher.watch macrosPath, (event) =>
      if event == 'change'
        @updateMacros()
      if event == 'delete'
        @clearToolbar()
        @makroSubscriptions?.dispose()


    atom.packages.activatePackage('toolbar')
      .then (pkg) =>
        @toolbar =  pkg.mainModule

        if @toolbar.toolbarView.children().length > 0
          @toolbar.appendSpacer()

        @updateMacros()


  deactivate: ->
    PathWatcher.close()
    @subscriptions.dispose()
    @makroSubscriptions?.dispose()

  serialize: ->
    undefined

  openMacros: ->
    macrosPath = @_getMacrosPath()
    if ! FS.existsSync(macrosPath)
      @_createTemplate(macrosPath)
    atom.workspace.open(macrosPath)


  updateMacrosWithUi: ->
    error = @updateMacros()
    unless error
      if @macros?.length
        alert 'Macros successfully reloaded:\n\n' + @_getMacrosNames(@macros).join(', ')
      else
        alert "No macros found in #{MACROS_FILE}"
    else
      @openMacros()
      alert "Error on macro reloaded: #{error.message}.\n\nPlease check the macros file."


  updateMacros: ->
    try
      macrosPath = @_getMacrosPath()
      if ! FS.existsSync(macrosPath)
        @_createTemplate(macrosPath)

      macros = @_getMacros(macrosPath)
      @macros = macros

      @addMacroCommands(macros)

      return null
    catch error
      console.error error
      return error


  addMacroCommands: (macros) ->
    @clearToolbar()
    @makroSubscriptions?.dispose()
    @makroSubscriptions = new CompositeDisposable
    for name in @_getMacrosNames(macros)
      method = macros[name]
      method.icon ?= 'ion-gear-a'
      method.title ?= name
      method.hideIcon ?= false

      commandName = "macros:#{name}"
      @makroSubscriptions.add atom.commands.add 'atom-workspace', commandName, method

      if @toolbar? && ! method.hideIcon
        icon = method.icon
        iconset = null

        if method.icon.substr(0,4) == 'ion-'
          icon = icon.substr(4)
          iconset = 'ion'

        if method.icon.substr(0,3) == 'fa-'
          icon = icon.substr(3)
          iconset = 'fa'

        button = @toolbar.appendButton icon, commandName, method.title, iconset
        button.addClass('macroButton')


  clearToolbar: ->
    return unless @toolbar?

    for button in @toolbar.toolbarView.children('.macroButton')
      button.remove()


  _getMacrosNames: (macros) ->
    return [] unless macros?
    return Object.keys(macros).filter (name) -> typeof macros[name] == 'function'


  _getMacrosPath: ->
    configDir = atom.getConfigDirPath()
    return PATH.resolve(configDir,MACROS_FILE)


  _createTemplate: (path) ->
    content = FS.readFileSync(PATH.resolve(__dirname,'../sample-macros.coffee'))
    FS.writeFileSync(path,content)

  _getMacros: (path) ->
    contents = FS.readFileSync(path,'utf8')
    jsCode = COFFEESCRIPT.compile(contents)
    jsCode = "var _c = {}; (function(){#{jsCode}}).call(_c); module.exports = _c;"
    macros = EVAL(jsCode,path,{console:console,atom:atom},true)
    return macros
