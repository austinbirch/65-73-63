class FrameAnimation
  constructor: ->
    @frame_duration = 0.15
    @display_duration = @frame_duration
    @current_frame = 0
    @sprite_width = 20
    @sprite_frames =
    [
      { name: 'stand', x: 0, y: 0 },
      { name: 'walk_1', x: 0, y: 0 },
      { name: 'walk_2', x: 0, y: 0 },
      { name: 'jump', x: 0, y: 0 }
    ]
    @frames = @sprite_frames

  animate: (delta) ->
    @display_duration -= delta

    if @display_duration <= 0
      # switch frame
      @current_frame++
      if @current_frame == @frames.length - 1
        @current_frame = 0

      @display_duration = @frame_duration

  get_sprite: ->
    return @get_frame_by_name(@frames[@current_frame].name)

  get_frame_by_name: (name) ->
    for index, frame of @sprite_frames
      if frame.name == name
        frame = {
          x: index * @sprite_width,
          y: 0,
          width: @sprite_width,
          height: 32
        }
        return frame

class @Runner extends Sprite
  
  constructor: (sprite) ->
    super
    # we are going to use the sprite given to create a spritesheet
    @frame_anim = new FrameAnimation
    @sprite = @gm.texture_manager.get_image_by_name('runner_anim')
    @alive = true
    @done_once = false
    @animating = true
    @velocity = new Vector(0, 0)
    @jumping = false

  jump: ->
    if @jumping == false
      @velocity.y =- 7
      @jumping = true

  update: (delta) ->
    if @animating
      @frame_anim.animate(delta)
  
  update_position: (delta) ->
    #console.log @velocity.y
    if @velocity.y == 0
      @jumping = false

    @velocity.y = @velocity.y + (@gm.GRAVITY * delta)
    @position.y += @velocity.y

  get_rect: ->
    @rect = new Rect(@position.x + 4, @position.y + 4, 20 - 4, 32 - 4)
    

  draw: (context) ->
    if @jumping == true
      frame = @frame_anim.get_frame_by_name('jump')
    else
      frame = @frame_anim.get_sprite()
    context.drawImage(@sprite, frame.x, frame.y, frame.width, frame.height, @position.x, @position.y, 20, 32)

