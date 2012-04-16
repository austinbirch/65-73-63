class @Bridge
  constructor: (collidable = true, type = 'bridge', out_delay = 0.7) ->
    @gm = Game.get()
    @position = new Vector(32, @gm.VIEW_HEIGHT - (@gm.TILE_HEIGHT * 2))
    @collidable = collidable
    @type = type
    @extension_width
    @direction
    @extension_level = 1
    @time_passed = 0
    @animation_time = 1/40
    @animating = false
    @reversing = false
    @finished_animating = true
    @out_delay = out_delay

  act: (delta) ->
    @time_passed += delta
    if @time_passed > @animation_time
      @time_passed = 0
      if not @reversing
         if @extension_level < @extension_width
           @extension_level++
         if @extension_level == @extension_width
           @reversing = true
           @time_passed = -@out_delay

       if @reversing
         if @extension_level > 1
           @extension_level--
         if @extension_level == 1
           @reversing = false
           @animating = false
        

  update: (delta) ->
    if @animating == true
      @act delta

  
  update_position: (camera_dx) ->
    @position.x -= camera_dx * (@gm.level.z_index / 2)


  get_rect: ->
    @rect = new Rect(0, 0, 32, 32)
    if @direction == 'right'
      @rect = new Rect(@position.x, @position.y, (@extension_level * 32), 32)
    if @direction == 'left'
      @rect = new Rect(@position.x - ((@extension_level * 32) - 32), @position.y, (@extension_level * 32), 32)
    return @rect
    
  draw: (context) ->
    context.fillStyle = 'rgb(0, 100, 0)'
    width = @extension_level * 32
    if @direction == 'right'
      context.fillRect(@position.x, @position.y, width, 32)
    if @direction == 'left'
      context.fillRect(@position.x - (width - 32), @position.y, width, 32)

    #context.strokeStyle = 'rgba(255, 0, 0, 0.5)'
    #rect = @get_rect()
    #context.strokeRect(rect.x, rect.y, rect.w, rect.h)
