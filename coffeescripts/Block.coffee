class @Block extends Sprite
  constructor: (sprite, collidable = "true", type = 'floor') ->
    super(sprite)
    @collidable = collidable
    @type = type
