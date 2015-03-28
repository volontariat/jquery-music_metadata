(($, window) ->
  MusicMetadata = {}
  
  # Define the plugin class
  MusicMetadata.Artists = class Artists
    jqueryInstanceMethodName: 'musicArtists'
    
    defaults:
      paramA: 'foo'

    constructor: (el, options) ->
      @init el, options if el
  
    init: (el, options) ->
      @options = $.extend({}, @defaults, options)
      @$el = $(el)
      $.data el, @constructor::jqueryInstanceMethodName, this
      #@el.addClass @constructor::jqueryInstanceMethodName
     
  # Original source from: http://blog.bitovi.com/writing-the-perfect-jquery-plugin/      
  $.pluginFactory = (plugin) ->
    $.fn[plugin::jqueryInstanceMethodName] = (options) ->
      args = $.makeArray(arguments)
      after = args.slice(1)
      
      @each ->
        instance = $.data(this, plugin::jqueryInstanceMethodName)
        
        if instance
          # call a method on the instance
          if typeof options == 'string'
            instance[options].apply instance, after
          else if instance.update
            # call update on the instance
            instance.update.apply instance, args
        else
          # create the plugin
          new plugin(this, options)        

  $.pluginFactory MusicMetadata.Artists
) window.jQuery, window