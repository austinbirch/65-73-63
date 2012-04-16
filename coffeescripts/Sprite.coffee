class @Sprite
  constructor: (sprite) ->
    @gm = Game.get()
    @sprite = @gm.texture_manager.get_image_by_name(sprite)
    @position = new Vector(32, @gm.VIEW_HEIGHT - (@gm.TILE_HEIGHT * 2))

  set_sprite: (sprite) ->
    @sprite = sprite

  update_position: (delta) ->
    @position.y += (@gm.GRAVITY * delta)

  set_position: (vector) ->
    @position = new Vector(vector.x, vector.y)

  get_rect: ->
    @rect = new Rect(@position.x, @position.y, @sprite.width, @sprite.height)

  draw: (context) ->
    context.drawImage(@sprite, @position.x, @position.y)
