(($, window) ->
  MusicMetadata = {}
  
  MusicMetadata.Base = class Base
    defaults:
      host: 'http://Volontari.at'

    constructor: (el, options) ->
      @init el, options if el
  
    init: (el, options) ->
      @options = $.extend({}, @defaults, options)
      @$el = $(el)
      $.data el, @constructor::jqueryInstanceMethodName, this
      #@el.addClass @constructor::jqueryInstanceMethodName
  
  # Define the plugin class
  MusicMetadata.Artists = class Artists extends MusicMetadata.Base
    jqueryInstanceMethodName: 'musicArtists'

    init: (el, options) ->
      super(el, options)
      
      tableHtml = """
        <table class="table table-striped">
          <thead>
            <tr class="odd">
              <th style="width: 200px">Name</th>
              <th style="width: 200px">Disambiguation</th>
              <th style="width: 75px">Founded at</th>
              <th style="width: 75px">Listeners</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td colspan="4" style="background-color:white;">
                <img src="https://i1.wp.com/cdnjs.cloudflare.com/ajax/libs/galleriffic/2.0.1/css/loader.gif" style="width:16px; height:16px;"/>
              </td>
            </tr>
          </tbody>
        </table> 
        <nav>
          <ul class="pagination">
          </ul>
        </nav>
      """
      @$el.html(tableHtml)
      
      @getPage(1, true)
      
    getPage: (pageNumber, init_pagination) -> 
      $.ajax(
        url: "#{@options['host']}/api/v1/music/artists.json?state=active&page=#{pageNumber}", type: 'GET', dataType: 'json'
      ).success((data) =>
        @$el.find('tbody').empty()
        
        $.each data['entries'], (index, artist) =>
          $.each artist, (attribute, value) ->
            switch attribute
              when 'founded_at'
                if value == null
                  artist[attribute] = ''
                else
                  date = new Date(value)
                  artist[attribute] = date.toLocaleDateString()
              else
                artist[attribute] = '' if value == null
          
          rowHtml = """
            <tr class="even">
              <td style="width: 200px">#{artist['name']}</td>
              <td style="width: 200px">#{artist['disambiguation']}</td>
              <td style="width: 75px">#{artist['founded_at']}</td>
              <td style="width: 75px">#{artist['listeners']}</td>
            </tr>
          """
          @$el.find('tbody').append(rowHtml)
        
        if init_pagination
          @$el.find('.pagination').pagination
            items: data['total_entries']
            itemsOnPage: data['per_page']
            currentPage: data['current_page']
            onPageClick: (pageNumber, event) =>
              @getPage(pageNumber, false)
      ).error((data) =>
        rowHtml = """
          <tr>
            <td colspan="4" style="background-color:white;">
              Failed to load artists!
            </td>
          </tr>
        """
        @$el.find('tbody').html(rowHtml)
      )
      
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