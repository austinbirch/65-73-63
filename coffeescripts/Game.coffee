class @Game extends Singleton

  GAMESTATE = { RUNNING: 1, NOT_STARTED: 2, PAUSED: 3, GAME_OVER: 4 }
  KEYS = { SPACE_BAR: 32, ESCAPE: 27, ENTER: 13 }

  constructor: ->
    # bind keyboard events to functions
    $(window).bind 'keydown',@keyDown
    $(window).bind 'keyup', @keyUp

    # constant widths and heights
    @TILE_WIDTH = 32
    @TILE_HEIGHT = 32
    @VIEW_HEIGHT = 480
    @VIEW_WIDTH = 768
    @GRAVITY = 0.07

    # for keeping track of keypresses
    @space_bar_down = false
    
    # set defaults for game
    @game_state = GAMESTATE.NOT_STARTED

    # the game timer
    @game_timer
    # for the game loop
    @frames_per_second = 60
    @current_fps = 0
    @previous_tick = 0
    @current_tick = 0
    @accumulator = 0
    @frame_count = 0

    # load images then initialise game objects
    @texture_manager = new TextureManager
    @texture_manager.add_image('sky', 'assets/images/sky.png')
    @texture_manager.add_image('buildings', 'assets/images/buildings.png')
    @texture_manager.add_image('buildings_far', 'assets/images/buildings_far.png')
    @texture_manager.add_image('runner_anim', 'assets/images/runner_anim.png')
    @texture_manager.add_image('floor', 'assets/images/floor.png')
    @texture_manager.load_images(@, @initGame)


    # interactable blocks
    @interactables_array = new Array()

    # begin the game
    #@initGame()

  initGame: ->
    # get a reference for the canvas
    @canvas = $('#game_canvas')
    @context = @canvas.get(0).getContext('2d')
    @canvas.attr('width', '768')
    @canvas.attr('height', '480')

    # set up the camera
    #@cameraX = @canvas.width() / 2
    #@cameraY = @canvas.height() / 2
    @camera_X = 0
    @camera_Y = 0
    @camera_dx = 0

    @score = 0

    # scenery layers
    @scenery_layers = new Array
    background_layer = new Layer
    buildings_layer = new Layer (2)
    buildings_far_layer = new Layer (1.5)
    background_layer.add_sprite(@texture_manager.get_image_by_name('sky'))
    buildings_layer.add_sprite(@texture_manager.get_image_by_name('buildings'))
    buildings_far_layer.add_sprite(@texture_manager.get_image_by_name('buildings_far'))
    @scenery_layers.push background_layer
    @scenery_layers.push buildings_far_layer
    @scenery_layers.push buildings_layer

    # for message display
    @player_message
    

    @runner = new Runner ('runner_anim')
    @runner_speed = 150


    # set the level
    @level = new Level
    @level.load_level @, @timeout

    #@timeout()

  update: (delta) ->

    if not @runner.alive
      # you've failed tom...
      @game_state = GAMESTATE.GAME_OVER

    switch @game_state
      when GAMESTATE.RUNNING
        @camera_position = @runner.position
        @camera_dx = @runner_speed * delta
        @camera_X += @camera_dx
        # update the background layers
        layer.update_position @camera_dx for layer in @scenery_layers
        # update the level position
        @level.update_position @camera_dx

        # update the runner position
        old_runner_pos = @runner.position
        @runner.update_position @camera_dx
        new_runner_pos = @runner.position
        # update the runner
        @runner.update delta

        # update the interactables
        interactable.update_position @camera_dx for interactable in @interactables_array

        # collision detection with the floor
        for index, block of @level.block_array
          # check to see if we should jump the runner
          if @runner.velocity.y == 0
            scan_distance = @runner.position.x + 32
            test_rect = new Rect(@runner.position.x, @runner.position.y + 8, scan_distance, 16)
            col_test = @collision_detect(block.get_rect(), test_rect)
            if col_test == true
              @runner.jump()

          collision = @collision_detect(@runner.get_rect(), block.get_rect())
          if collision == true
            # there is a collision, so stop the player
            @runner.set_position(new Vector(@runner.position.x, block.position.y - 32))
            @runner.velocity.y = 0
        ## collision detection with interactables
        for index, interactable of @interactables_array
          collision = @collision_detect(@runner.get_rect(), interactable.get_rect())
          if collision == true
            # there is a collision, so stop the player
            @runner.set_position(new Vector(@runner.position.x, interactable.position.y - 32))


        # check to see whether Tom has fallen to his death
        if @runner.position.y > @VIEW_HEIGHT
          @runner.alive = false

        # let's play with the interactables
        for index, interactable of @interactables_array
          if @space_bar_down
            if interactable.animating == false
              interactable.animating = true
          interactable.update delta



      when GAMESTATE.NOT_STARTED
        @player_message = null
      when GAMESTATE.GAME_OVER
        @player_message = "Tom died a horrible death. The Bees are coming!"
        
  collision_detect: (rect_a, rect_b) ->
    left_a = rect_a.x
    right_a = rect_a.x + rect_a.w
    top_a = rect_a.y
    bottom_a = rect_a.y + rect_a.h
    
    left_b = rect_b.x
    right_b = rect_b.x + rect_b.w
    top_b = rect_b.y
    bottom_b = rect_b.y + rect_b.h

    if bottom_a < top_b
      return false
    if top_a > bottom_b
      return false
    if right_a < left_b
      return false
    if left_a > right_b
      return false
    
    # there has been a collision
    return true

  render: ->
    @context.fillStyle = 'rgb(255, 255, 255)'
    @context.fillRect(0, 0, @canvas.width(), @canvas.height())

    # render the bg
    layer.draw @context for layer in @scenery_layers
    #@background.draw @context
    #@buildings_far.draw @context
    #@buildings.draw @context
    
    # draw the runner
    @runner.draw @context

    #if @test_rect?
      #@context.strokeStyle = 'rgb(255, 0, 0)'
      #@context.strokeRect(@test_rect.x, @test_rect.y, @test_rect.w, @test_rect.h)

    # draw the level
    @level.draw @context

    # draw the interactables
    for index, interactable of @interactables_array
      interactable.draw @context

    @context.fillStyle = 'rgb(255, 255, 255)'
    @context.font = '12px Georgia'
    @context.fillText('fps: ' + @current_fps, 10, 20)
    @context.font = '16px Georgia'
    @context.fillText(@score + 'm', 10, @VIEW_HEIGHT - 10)

    # if there is a message to display, display it
    @context.font = '22px Georgia'
    if @player_message
      if @player_message.indexOf("horrible") != -1
        @context.fillStyle = 'rgba(0, 0, 0, 0.8)'
        @context.fillRect 10, 32, 490, 130
        @context.fillStyle = 'rgb(255, 255, 255)'
        @context.fillText @player_message, 20, 70
        @context.fillText "Your escape lasted #{@score}m.", 20, 100
        @context.fillText 'Reload to restart.', 20, 150
      else
        @context.fillStyle = 'rgba(0, 0, 0, 0.8)'
        @context.fillRect 10, 32, 360, 60
        @context.fillStyle = 'rgb(255, 255, 255)'
        @context.fillText @player_message, 20, 73
    else
      if @game_state == GAMESTATE.NOT_STARTED
        @context.fillStyle = 'rgba(0, 0, 0, 0.8)'
        @context.fillRect 10, 32, 360, 60
        @context.fillStyle = 'rgb(255, 255, 255)'
        @context.fillText 'Press ENTER to help Tom escape.', 20, 73


  timeout: ->
    @previous_tick = @current_tick
    @current_tick = (new Date).getTime()
    # call update with a delta
    delta = @current_tick - @previous_tick
    # store delta and test fps
    @accumulator += delta
    if @accumulator >= 1000/12
      if @game_state == GAMESTATE.RUNNING
        @score = @score + 1
    if @accumulator >= 1000
      # reset frame count
      @current_fps = @frame_count
      @frame_count = 1
      @accumulator = 0
    else
      # not greater than a second, count another frame
      @frame_count += 1

    # call update then render
    @update(delta/1000)
    @render()
    self = @
    @game_timer = setTimeout((-> self.timeout()), 1000/@frames_per_second)

  keyDown: (event) =>
    switch event.keyCode
      when KEYS.SPACE_BAR
        @space_bar_down = true
        event.preventDefault()
      when KEYS.ENTER
        if @game_state == GAMESTATE.NOT_STARTED or GAMESTATE.PAUSED
          @game_state = GAMESTATE.RUNNING
          @player_message = ""
        event.preventDefault()
      when KEYS.ESCAPE
        @escape_down = true
        if @game_state == GAMESTATE.RUNNING
          @game_state = GAMESTATE.PAUSED
          @player_message = "Press ENTER to resume."
        event.preventDefault()

  keyUp: (event) =>
    switch event.keyCode
      when KEYS.SPACE_BAR
        @space_bar_down = false
