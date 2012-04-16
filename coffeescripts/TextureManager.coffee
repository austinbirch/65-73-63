class @TextureManager

  #constructor: ->
    #@image_asset_path = '/assets/images/'
    #@json_texture_files = [ 'textures.json' ]
    #@json_textures = new Array
    #@images = new Array

    #console.log('load json')
    #$.getJSON 'assets/images/textures.json', (data) =>
      #console.log data
      #file_array = { image: data.meta.image }
      #file_array = { textures: data.frames }
      #@json_textures.push file_array
      #@load_textures()


  #load_textures: ->
    #console.log @json_textures
    #@get_texture_by_name('sky')

  #get_texture_by_name: (name) ->
    #for key, value in @json_textures
      #if key == 'textures'
        #for key,value in value
          #console.log value
  
  constructor: ->
    @images = {}
    @image_sources = {}
    @image_count = 0
    @image_load_count = 0
    @tmpImage = {}

  add_image: (name, path) ->
    if name != '' and path != ''
      @image_sources[name] = path
      @image_count++

  load_images: (context, callback) ->
    console.log 'load_images'
    for k,v of @image_sources
      @tmpImage[k] = new Image

      self = @
      @tmpImage[k].onload = ->
        console.log @src + ' loaded.'
        self.images[@id] = self.tmpImage[@id]
        self.image_load_count++

        if self.image_load_count == self.image_count
          callback.call context
          

      @tmpImage[k].src = v
      @tmpImage[k].id = k

      

  get_image_by_name: (name) ->
    return @images[name]

