class @Singleton

  __instance = null

  @get: ->
    if not @__instance?
      @__instance = new @
      @__instance.init()

    @__instance

  init: (name = 'unknown') ->
    console.log "#{name} was initialized"
