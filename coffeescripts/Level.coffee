class @Level

  constructor: ->
    @gm = Game.get()
    @floor_tile = @gm.texture_manager.get_image_by_name('floor')
    @z_index = 2.5
    @level_array = new Object
    @block_array = new Array
    @position = new Vector(0, 0)
    @done_once = false
    @floor_pos = 480 - 32

  load_level: (context, callback) ->
    console.log('load json')
    $.getJSON 'assets/levels/level.json', (data) =>
      console.log 'loading level...'
      #@level_array = data
      for column, col_pos in data
        for index, block of column
          if !block.type
            for key, value of block
              tmp_block = new Block('floor', true)
              tmp_block.position.x = col_pos * @gm.TILE_WIDTH
              tmp_block.position.y = (@gm.VIEW_HEIGHT - 32) - (value * @gm.TILE_HEIGHT)
              @block_array.push tmp_block
          if block.type == 'bridge'
            tmp_block = new Bridge
            for key, value of block
              if key == 'height'
                tmp_block.position.x = col_pos * @gm.TILE_WIDTH
                tmp_block.position.y = (@gm.VIEW_HEIGHT - 32) - (value * @gm.TILE_HEIGHT)
              if key == 'out_delay'
                tmp_block.out_delay = value
            tmp_block.direction =  block.direction
            tmp_block.extension_width = parseInt(block.extension_width) + 1
            @gm.interactables_array.push tmp_block
              

      callback.call context

  update_position: (camera_dx) ->
    @position.x -= camera_dx * (@z_index / 2)
    # update the position of the blocks
    for index, block of @block_array
      block.position.x -= camera_dx * (@z_index / 2)

  draw: (context) ->
    context.fillStyle = 'rgb(112, 112, 112)'
    for index, block of @block_array
      #if @done_once == false
        #console.log block
        #@done_once = true
      if block.type == 'floor'
        context.fillRect(block.position.x, block.position.y, 32, 32)
