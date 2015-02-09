# License: MIT

{CompositeDisposable} = require 'atom'
PATH = require 'path'
FS = require 'fs'
COFFEESCRIPT = require 'coffee-script'
EVAL = require 'eval'
PathWatcher = require 'pathwatcher'

MACROS_FILE = 'macros.coffee'
PREPEND_FILE = 'prepend.coffee'
SAMPLE_FILE = 'sample-macros.coffee'

module.exports = Macros =
  subscriptions: null
  macroCommandSubscriptions: null
  macros: {}
  toolbar: null
  prepend: null
  macroMenuDisposable: null
  macroDisposable: null

  activate: (state) ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'macros:edit-macros': => @openMacros()
    @subscriptions.add atom.commands.add 'atom-workspace', 'macros:reload-macros': => @updateMacrosWithUi()

    setImmediate(@_initialize.bind(this)) # delay to improve startup behavior


  deactivate: ->
    @_callOnUnloadAsync()
    .then =>
      @watch?.close()
      @subscriptions.dispose()
      @macroCommandSubscriptions?.dispose()
      @macroDisposable?.dispose()

  serialize: ->
    undefined


  _initialize: ->
    @updateMacros()
    macrosPath = @_getMacrosPath()

    @watch = PathWatcher.watch macrosPath, (event) =>
      if event == 'change'
        FS.stat macrosPath, (err,stat) =>
          return unless stat?
          # sometimes the event is triggered twice...
          mTime = stat.mtime?.getTime()
          return if mTime == @lastMTime
          @lastMTime = mTime

          @updateMacros()

      if event == 'delete'
        @clearToolbar()
        @macroCommandSubscriptions?.dispose()

    atom.packages.activatePackage('toolbar')
      .then (pkg) =>
        @toolbar =  pkg.mainModule

        @addMacroCommands()


  openMacros: ->
    macrosPath = @_getMacrosPath()
    if ! FS.existsSync(macrosPath)
      @_createTemplate(macrosPath)
    atom.workspace.open(macrosPath)


  updateMacrosWithUi: ->
    error = @updateMacros()
    unless error
      if @macros?
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

      @_callOnUnloadAsync()
      .then =>
        @macros = macros

        @addMacroCommands(macros)

        return @_callOnLoadAsync()
    catch error
      console.error error.stack
      return error


  addMacroCommands: (macros) ->
    @_clearToolbar()
    @_clearMacroMenu()

    @macroCommandSubscriptions?.dispose()
    @macroCommandSubscriptions = new CompositeDisposable

    macroMenu = []

    for own name, method of @macros
      continue unless name?
      continue if name.substr(0,2) == 'on' # handlers are not added as macros

      unless typeof method == 'function'
        @_appendSpacer() if @toolbar?
        macroMenu.push {
          'type': 'separator'
        }
        continue

      method.icon ?= 'ion-gear-a'
      method.title ?= name
      method.hideIcon ?= false

      commandName = "macros:#{name}"
      @macroCommandSubscriptions.add atom.commands.add 'atom-workspace', commandName, method

      macroMenu.push {
        'label': method.title
        'command': commandName
      }

      if @toolbar? && ! method.hideIcon
        icon = method.icon
        iconset = null

        if method.icon.substr(0,4) == 'ion-'
          icon = icon.substr(4)
          iconset = 'ion'

        if method.icon.substr(0,3) == 'fa-'
          icon = icon.substr(3)
          iconset = 'fa'

        if method.icon.substr(0,8) == 'octicon-'
          icon = icon.substr(8)
          iconset = ''

        button = @toolbar.appendButton icon, commandName, method.title, iconset
        button.addClass('macroButton')

    @_addMacroMenu(macroMenu)


  _clearToolbar: ->
    return unless @toolbar?

    for button in @toolbar.toolbarView.children('.macroButton')
      button.remove()

    if @toolbar.toolbarView.children().length > 0
      @_appendSpacer()


  _appendSpacer: ->
    return unless @toolbar?
    @toolbar.appendSpacer()
    spacer = @toolbar.toolbarView.children().last()
    spacer.addClass('macroButton')


  _getMacrosNames: (macros) ->
    return [] unless macros?
    return Object.keys(macros).filter (name) -> typeof macros[name] == 'function'


  _clearMacroMenu: ->
    @macroMenuDisposable?.dispose()


  _addMacroMenu: (macroMenu) ->
    @macroMenuDisposable = atom.menu.add [
      {
        'label': 'Packages'
        'submenu': [
          'label': 'Macros'
          'submenu': [
            {
              'label': 'User-defined macros'
              'submenu': macroMenu
            }
          ]
        ]
      }
    ]


  _getMacrosPath: ->
    configDir = atom.getConfigDirPath()
    return PATH.resolve(configDir,MACROS_FILE)


  _createTemplate: (path) ->
    content = FS.readFileSync(PATH.resolve(__dirname,SAMPLE_FILE))
    FS.writeFileSync(path,content)

  _getMacros: (path) ->
    @_loadPrependFile() unless @prepend?
    contents = FS.readFileSync(path,'utf8')
    contents = @prepend + contents if @prepend?
    jsCode = COFFEESCRIPT.compile(contents)
    jsCode = "var _c = {}; (function(){#{jsCode}}).call(_c); module.exports = _c;"

    @macroDisposable?.dispose()
    @macroDisposable = new CompositeDisposable

    macros = EVAL(
      jsCode
      path
      {
        console:console
        subscriptions:@macroDisposable
        setTimeout:window.setTimeout
        clearTimeout:window.clearTimeout
        setInterval:window.setInterval
        clearInterval:window.clearInterval
        JSON:JSON
      },true)

    return macros

  _loadPrependFile: ->
    try
      @prepend = FS.readFileSync(PATH.join(__dirname,PREPEND_FILE),'utf8')
    catch error
      console.error error


  _callOnLoadAsync: ->
    result = @macros?.onLoad?()
    @_returnThenable(result)


  _callOnUnloadAsync: ->
    result = @macros?.onUnload?()
    @_returnThenable(result)


  _returnThenable: (result) ->
    if typeof result?.then == 'function'
      return result # It's a thenable

    return then: (cb) => cb?()
