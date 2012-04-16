class @Layer
  
  constructor: (z_index = 1) ->
    @z_index = z_index
    @sprites = []
    @position = new Vector(0, 0)

  add_sprite: (image) ->
    @sprites.push image
  
  remove_sprite: (image) ->
    console.log 'remove the sprite ' + image

  update_position: (cam_dx) ->
    @position.x -= cam_dx * (@z_index / 2)

  draw: (context) ->
    if @position.x < (0 - @sprites[0].width)
      # it is full off of the left hand side
      @position.x = 0
    context.drawImage @sprites[0], @position.x, @position.y
    context.drawImage @sprites[0], (@position.x - 1) + @sprites[0].width, @position.y
