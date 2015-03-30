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
  
  MusicMetadata.Artists = class Artists extends MusicMetadata.Base
    jqueryInstanceMethodName: 'musicArtists'

    init: (el, options) ->
      super(el, options)
      @showHeadAndPage(1)
    
    showHeadAndPage: (pageNumber) ->
      tableHtml = """
        <table class="table table-striped">
          <thead>
            <tr class="odd">
              <th style="width: 300px;">Name</th>
              <th>Disambiguation</th>
              <th style="width: 75px;">Founded at</th>
              <th style="width: 75px;">Dissolved at</th>
              <th style="width: 75px;">Listeners</th>
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
      
      @showPage(pageNumber, true)  
      
    showPage: (pageNumber, init_pagination) -> 
      @$el.data('current-page', pageNumber)
      
      $.ajax
        url: "#{@options['host']}/api/v1/music/artists.json?state=active&page=#{pageNumber}"
        type: 'GET'
        dataType: 'json'
        success: (data) =>
          @$el.find('tbody').empty()
          
          if data['entries'].length == 0
            rowHtml = """
              <tr>
                <td colspan="4" style="background-color:white;">
                  No artists found!
                </td>
              </tr>
            """
            @$el.find('tbody').html(rowHtml)
          else
            $.each data['entries'], (index, artist) =>
              $.each artist, (attribute, value) ->
                switch attribute
                  when 'founded_at', 'dissolved_at'
                    if value == null
                      artist[attribute] = ''
                    else
                      date = new Date(value)
                      artist[attribute] = date.toLocaleDateString()
                  else
                    artist[attribute] = '' if value == null
              
              rowHtml = """
                <tr class="even">
                  <td style="width: 300px;"><a class="music_artist_link" href="#" data-id="#{artist['id']}">#{artist['name']}</a></td>
                  <td>#{artist['disambiguation']}</td>
                  <td style="width: 75px">#{artist['founded_at']}</td>
                  <td style="width: 75px">#{artist['dissolved_at']}</td>
                  <td style="width: 75px">#{artist['listeners']}</td>
                </tr>
              """
              @$el.find('tbody').append(rowHtml)
            
            @$el.find('.music_artist_link').on 'click', (event) =>
              event.preventDefault()
              
              lastPage = @$el.data('current-page')
              @$el.data('artist-id', $(event.target).data('id'))
              @$el.data('last-artists-page', lastPage)
              @$el.musicArtist('showMetadata')
            
            if init_pagination
              @$el.find('.pagination').pagination
                items: data['total_entries']
                itemsOnPage: data['per_page']
                currentPage: data['current_page']
                onPageClick: (pageNumber, event) =>
                  @showPage(pageNumber, false)
         
        error: (data) =>
          rowHtml = """
            <tr>
              <td colspan="4" style="background-color:white;">
                Failed to load artists!
              </td>
            </tr>
          """
          @$el.find('tbody').html(rowHtml)
          
  MusicMetadata.Artist = class Artist extends MusicMetadata.Base
    jqueryInstanceMethodName: 'musicArtist'

    init: (el, options) ->
      super(el, options)
      
      @showMetadata()

    showMetadata: ->
      $.ajax
        url: "#{@options['host']}/api/v1/music/artists/#{@$el.data('artist-id')}.json", type: 'GET', dataType: 'json'
        success: (data) =>
          pageHtml = """
            <ol class="breadcrumb">
              <li><a class="music_artists_link" href="#">Artists</a></li>
              <li class="active">#{data['name']}</li>
            </ol>
            
            <h2>Albums & EPs</h2>
            
            <table id="music_releases" class="table table-striped">
              <thead>
                <tr class="odd">
                  <th style="width: 100px">Released at</th>
                  <th>Name</th>
                  <th style="width: 75px">Type</th>
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
          """
          
          @$el.html(pageHtml)
          
          @$el.find('.music_artists_link').on 'click', =>
            if @$el.data('musicArtists')
              @$el.musicArtists('showHeadAndPage', @$el.data('last-artists-page') || 1)
            else
              @$el.musicArtists()
          
          @showReleases()    
        error: (data) =>
          if data.status == 404
            alert 'Artist not found!'
          else
            alert 'Failed to load artist!'

    showReleases: ->
      $.ajax
        url: "#{@options['host']}/api/v1/music/artists/#{@$el.data('artist-id')}/releases.json", type: 'GET', dataType: 'json'
        success: (data) =>
          $('#music_releases tbody').empty()
          
          if data.length == 0
            rowHtml = """
              <tr>
                <td colspan="4" style="background-color:white;">No releases found!</td>
              </tr>
            """
            $('#music_releases tbody').html(rowHtml)
          else
            $.each data, (index, release) =>
              $.each release, (attribute, value) ->
                if value == null
                  release[attribute] = ''
                else
                  switch attribute
                    when 'released_at'
                      if release['future_release_date'] != null && release['future_release_date'] != ''
                        release[attribute] = release['future_release_date']
                      else
                        date = new Date(value)
                        release[attribute] = date.toLocaleDateString()
              
              type = if release['is_lp'] then 'Album' else 'EP'
              
              rowHtml = """
                <tr class="even">
                  <td style="width: 100px">#{release['released_at']}</td>
                  <td><a class="music_release_link" href="#" data-id="#{release['id']}">#{release['name']}</a></td>
                  <td style="width: 75px">#{type}</td>
                  <td style="width: 75px">#{release['listeners']}</td>
                </tr>
              """
              $('#music_releases tbody').append(rowHtml)
            
            @$el.find('.music_release_link').on 'click', (event) =>
              event.preventDefault()
              @$el.removeData 'musicRelease'
              @$el.data('release-id', $(event.target).data('id'))
              
              if @$el.data('musicRelease')
                @$el.musicRelease('showMetadata')
              else
                @$el.musicRelease()
        error: (data) =>
          rowHtml = """
            <tr>
              <td colspan="4" style="background-color:white;">
                Failed to load releases!
              </td>
            </tr>
          """
          $('#music_releases tbody').html(rowHtml)
      
  MusicMetadata.Release = class Release extends MusicMetadata.Base
    jqueryInstanceMethodName: 'musicRelease'

    init: (el, options) ->
      super(el, options)
      
      @showMetadata()

    showMetadata: ->
      $.ajax
        url: "#{@options['host']}/api/v1/music/releases/#{@$el.data('release-id')}.json", type: 'GET', dataType: 'json'
        success: (data) =>
          pageHtml = """
            <ol class="breadcrumb">
              <li><a class="music_artists_link" href="#">Artists</a></li>
              <li><a class="music_artist_link" href="#" data-id="#{data['artist_id']}">#{data['artist_name']}</a></li>
              <li class="active">#{data['name']}</li>
            </ol>
            
            <h2>Tracks</h2>
            
            <table id="music_tracks" class="table table-striped">
              <thead>
                <tr class="odd">
                  <th style="width: 50px">Nr</th>
                  <th>Name</th>
                  <th style="width: 75px">Duration</th>
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
          """
          
          @$el.html(pageHtml)
          
          @$el.find('.music_artists_link').on 'click', =>
            #@$el.removeAttr @constructor::jqueryInstanceMethodName
            if @$el.data('musicArtists')
              @$el.musicArtists('showHeadAndPage', @$el.data('last-artists-page') || 1)
            else
              @$el.musicArtists()
         
          @$el.find('.music_artist_link').on 'click', (event) =>
            event.preventDefault()
            @$el.data('artist-id', $(event.target).data('id'))
            
            if @$el.data('musicArtist')
              @$el.musicArtist('showMetadata')
            else
              @$el.musicArtist()
          
          @showTracks()    
        error: (data) =>
          if data.status == 404
            alert 'Release not found!'
          else
            alert 'Failed to load release!'

    showTracks: ->
      $.ajax
        url: "#{@options['host']}/api/v1/music/releases/#{@$el.data('release-id')}/tracks.json", type: 'GET', dataType: 'json'
        success: (data) =>
          $('#music_tracks tbody').empty()
          
          if data.length == 0
            rowHtml = """
              <tr>
                <td colspan="4" style="background-color:white;">No tracks found!</td>
              </tr>
            """
            $('#music_tracks tbody').html(rowHtml)
          else
            $.each data, (index, track) =>
              $.each track, (attribute, value) ->
                track[attribute] = '' if value == null
              
              rowHtml = """
                <tr class="even">
                  <td style="width: 50px; text-align:right;">#{track['nr']}</td>
                  <td><a class="music_track_link" href="#" data-id="#{track['id']}">#{track['name']}</a></td>
                  <td style="width: 75px;">#{track['duration']}</td>
                  <td style="width: 75px;">#{track['listeners']}</td>
                </tr>
              """
              $('#music_tracks tbody').append(rowHtml)
            
            @$el.find('.music_track_link').on 'click', (event) =>
              event.preventDefault()
              @$el.data('track-id', $(event.target).data('id'))
              
              if @$el.data('musicTrack')
                @$el.musicTrack('showMetadata')
              else
                @$el.musicTrack()
        error: (data) =>
          rowHtml = """
            <tr>
              <td colspan="4" style="background-color:white;">
                Failed to load tracks!
              </td>
            </tr>
          """
          @$el.find('tbody').html(rowHtml)

  MusicMetadata.Track = class Track extends MusicMetadata.Base
    jqueryInstanceMethodName: 'musicTrack'

    init: (el, options) ->
      super(el, options)
      
      @showMetadata()

    showMetadata: ->
      $.ajax
        url: "#{@options['host']}/api/v1/music/tracks/#{@$el.data('track-id')}.json", type: 'GET', dataType: 'json'
        success: (data) =>
          pageHtml = """
            <ol class="breadcrumb">
              <li><a class="music_artists_link" href="#">Artists</a></li>
              <li><a class="music_artist_link" href="#" data-id="#{data['artist_id']}">#{data['artist_name']}</a></li>
              <li><a class="music_release_link" href="#" data-id="#{data['release_id']}">#{data['release_name']}</a></li>
              <li class="active">#{data['name']}</li>
            </ol>
            
            <h2>Videos</h2>
            
            <div id="music_videos">
              <img src="https://i1.wp.com/cdnjs.cloudflare.com/ajax/libs/galleriffic/2.0.1/css/loader.gif" style="width:16px; height:16px;"/>
            </div>
          """
          
          @$el.html(pageHtml)
          
          @$el.find('.music_artists_link').on 'click', =>
            if @$el.data('musicArtists')
              @$el.musicArtists('showHeadAndPage', @$el.data('last-artists-page') || 1)
            else
              @$el.musicArtists()
         
          @$el.find('.music_artist_link').on 'click', (event) =>
            event.preventDefault()
            @$el.data('artist-id', $(event.target).data('id'))
            
            if @$el.data('musicArtist')
              @$el.musicArtist('showMetadata')
            else
              @$el.musicArtist()
  
          @$el.find('.music_release_link').on 'click', (event) =>
            event.preventDefault()
            @$el.data('release-id', $(event.target).data('id'))
            
            if @$el.data('musicRelease')
              @$el.musicRelease('showMetadata')
            else
              @$el.musicRelease()
          
          @showVideos()    
        error: (data) =>
          if data.status == 404
            alert 'Track not found!'
          else
            alert 'Failed to load track!'

    showVideos: ->
      $.ajax
        url: "#{@options['host']}/api/v1/music/tracks/#{@$el.data('track-id')}/videos.json", type: 'GET', dataType: 'json'
        success: (data) =>
          $('#music_videos').empty()
          
          if data.length == 0
            $('#music_videos').html('No videos available!')
          else
            $.each data, (index, video) =>
              $.each video, (attribute, value) ->
                video[attribute] = '' if value == null
              
              rowHtml = """
                <h3>#{video['artist_name']} – #{video['track_name']} (#{video['status']})</h3>
                <p>
                  <a href="#{video['url']}" class="oembed"></a>
                </p>
              """
              $('#music_videos').append(rowHtml)
              
            $('#music_videos .oembed').oembed()
        error: (data) =>
          rowHtml = """
            <tr>
              <td colspan="4" style="background-color:white;">Failed to load videos!</td>
            </tr>
          """
          $('#music_videos').html(rowHtml)

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
  $.pluginFactory MusicMetadata.Artist 
  $.pluginFactory MusicMetadata.Release 
  $.pluginFactory MusicMetadata.Track  
) window.jQuery, window