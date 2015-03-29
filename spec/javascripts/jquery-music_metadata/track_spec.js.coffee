describe 'MusicMetadata.Track', ->
  beforeEach ->
    jasmine.Ajax.install()
    window.alert = jasmine.createSpy()
    affix '#music_track_page[data-track-id="74"]'
    jasmine.Ajax.requests.reset()
    
  describe '#showMetadata and #showVideos', ->
    describe 'successful response', -> 
      describe 'successful videos response', ->
        describe 'with videos', ->
          it 'adds a breadcrumb with an artist link, release link plus track name and list with 1 video', ->
            $('#music_track_page').musicTrack()
            
            request = jasmine.Ajax.requests.at(0)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/tracks/74.json')
            body = """
              {
                "id":74,"mbid":"2b9f4a03-086f-4108-a32f-99ed775655c7","spotify_id":"6WK9dVrRABMkUXFLNlgWFh",
                "nr":6,"master_track_id":null,"artist_id":1,"artist_name":"Depeche Mode","name":"Enjoy The Silence",
                "release_id":8,"release_name":"Violator","duration":"06:13","released_at":"1990-02-21T00:00:00Z",
                "listeners":796647,"plays":5947341,"state":"active"
              }
            """
            request.respondWith
              status: 200
              responseText: body
              
            request = jasmine.Ajax.requests.at(1)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/tracks/74/videos.json')
            body = """
              [
                {
                  "id":1,"status":"Official","artist_id":1,"artist_name":"Depeche Mode","track_id":74,
                  "track_name":"Enjoy The Silence","url":"https://vimeo.com/26842471"
                }
              ]
            """
            request.respondWith
              status: 200
              responseText: body  
            
            expect($('.breadcrumb .music_artist_link:contains("Depeche Mode")').length).toBe(1)
            expect($('.breadcrumb .music_release_link:contains("Violator")').length).toBe(1)
            expect($('.breadcrumb .active:contains("Enjoy The Silence")').length).toBe(1)
            expect($($('#music_videos a')[0]).attr('href')).toBe('https://vimeo.com/26842471')
            
        describe 'without tracks', ->
          it 'it adds an error message as first row of tracks', ->
            $('#music_track_page').musicTrack()
            
            request = jasmine.Ajax.requests.at(0)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/tracks/74.json')
            body = """
              {
                "id":74,"mbid":"2b9f4a03-086f-4108-a32f-99ed775655c7","spotify_id":"6WK9dVrRABMkUXFLNlgWFh",
                "nr":6,"master_track_id":null,"artist_id":1,"artist_name":"Depeche Mode","name":"Enjoy The Silence",
                "release_id":8,"release_name":"Violator","duration":"06:13","released_at":"1990-02-21T00:00:00Z",
                "listeners":796647,"plays":5947341,"state":"active"
              }
            """
            request.respondWith
              status: 200
              responseText: body
              
            request = jasmine.Ajax.requests.at(1)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/tracks/74/videos.json')
            request.respondWith
              status: 200
              responseText: "[]"  
            
            expect($('.breadcrumb .music_artist_link:contains("Depeche Mode")').length).toBe(1)
            expect($('.breadcrumb .music_release_link:contains("Violator")').length).toBe(1)
            expect($('.breadcrumb .active:contains("Enjoy The Silence")').length).toBe(1)
            expect($('#music_videos:contains("No videos available!")').length).toBe(1)
            
      describe 'faulty videos response', ->
        it 'it adds an error message as first row of tracks', ->
          $('#music_track_page').musicTrack()
            
          request = jasmine.Ajax.requests.at(0)
          expect(request.url).toBe('http://Volontari.at/api/v1/music/tracks/74.json')
          body = """
            {
              "id":74,"mbid":"2b9f4a03-086f-4108-a32f-99ed775655c7","spotify_id":"6WK9dVrRABMkUXFLNlgWFh",
              "nr":6,"master_track_id":null,"artist_id":1,"artist_name":"Depeche Mode","name":"Enjoy The Silence",
              "release_id":8,"release_name":"Violator","duration":"06:13","released_at":"1990-02-21T00:00:00Z",
              "listeners":796647,"plays":5947341,"state":"active"
            }
          """
          request.respondWith
            status: 200
            responseText: body
            
          request = jasmine.Ajax.requests.at(1)
          expect(request.url).toBe('http://Volontari.at/api/v1/music/tracks/74/videos.json')
          request.respondWith
            status: 500
            responseText: "[]"  
          
          expect($('.breadcrumb .music_artist_link:contains("Depeche Mode")').length).toBe(1)
          expect($('.breadcrumb .music_release_link:contains("Violator")').length).toBe(1)
          expect($('.breadcrumb .active:contains("Enjoy The Silence")').length).toBe(1)
          expect($('#music_videos:contains("Failed to load videos!")').length).toBe(1)
          
    describe 'faulty response', ->
      describe 'status is 404', ->
        it 'alerts an message', ->
          $('#music_track_page').musicTrack()
            
          request = jasmine.Ajax.requests.mostRecent()
          expect(request.url).toBe('http://Volontari.at/api/v1/music/tracks/74.json')
          request.respondWith
            status: 404
            responseText: "{}"
        
          expect(window.alert).toHaveBeenCalledWith('Track not found!')
          
      describe 'status is other than 404', ->
        it 'alerts an message', ->
          $('#music_track_page').musicTrack()
            
          request = jasmine.Ajax.requests.mostRecent(0)
          expect(request.url).toBe('http://Volontari.at/api/v1/music/tracks/74.json')
          request.respondWith
            status: 500
            responseText: "{}"
        
          expect(window.alert).toHaveBeenCalledWith('Failed to load track!')