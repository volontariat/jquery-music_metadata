describe 'MusicMetadata.Release', ->
  beforeEach ->
    jasmine.Ajax.install()
    window.alert = jasmine.createSpy()
    affix '#music_release_page[data-release-id="2"]'
    jasmine.Ajax.requests.reset()
    
  describe '#showMetadata and #showTracks', ->
    describe 'successful response', -> 
      describe 'successful tracks response', ->
        describe 'with tracks', ->
          it 'adds a breadcrumb with an artist link plus release name and list with 1 track', ->
            $('#music_release_page').musicRelease()
            
            request = jasmine.Ajax.requests.at(0)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/releases/2.json')
            body = """
              {
                "id": 2, "mbid":"517e51e2-cd92-4d03-b1ae-b62b0c45a77e", "spotify_id":"1YqWw5boCxSxGEkohvBvD6",
                "is_lp":true,"artist_id":1,"artist_name":"Depeche Mode","name":"Speak & Spell",
                "future_release_date":null,"released_at":"1981-10-05T00:00:00Z","listeners":251753,
                "plays":2631138,"state":"active"
              }
            """
            request.respondWith
              status: 200
              responseText: body
              
            request = jasmine.Ajax.requests.at(1)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/releases/2/tracks.json')
            body = """
              [
                {
                  "id":1,"mbid":"07075a19-e37b-4f9d-869c-ec98e0ceebb6","spotify_id":"0c5Uw4APNPrGdEU3K9xMrQ",
                  "nr":1,"master_track_id":null,"artist_id":1,"artist_name":"Depeche Mode","name":"New Life",
                  "release_id":2,"release_name":"Speak & Spell","duration":"03:46","released_at":"1981-10-05T00:00:00Z",
                  "listeners":176902,"plays":757916,"state":"active"
                }
              ]
            """
            request.respondWith
              status: 200
              responseText: body  
            
            expect($('.breadcrumb .music_artist_link:contains("Depeche Mode")').length).toBe(1)
            expect($('.breadcrumb .active:contains("Speak & Spell")').length).toBe(1)
            expect($('#music_tracks .music_track_link:contains("New Life")').length).toBe(1)
            
        describe 'without tracks', ->
          it 'it adds an error message as first row of tracks', ->
            $('#music_release_page').musicRelease()
            
            request = jasmine.Ajax.requests.at(0)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/releases/2.json')
            body = """
              {
                "id": 2, "mbid":"517e51e2-cd92-4d03-b1ae-b62b0c45a77e", "spotify_id":"1YqWw5boCxSxGEkohvBvD6",
                "is_lp":true,"artist_id":1,"artist_name":"Depeche Mode","name":"Speak & Spell",
                "future_release_date":null,"released_at":"1981-10-05T00:00:00Z","listeners":251753,
                "plays":2631138,"state":"active"
              }
            """
            request.respondWith
              status: 200
              responseText: body
              
            request = jasmine.Ajax.requests.at(1)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/releases/2/tracks.json')
            request.respondWith
              status: 200
              responseText: "[]"  
            
            expect($('.breadcrumb .music_artist_link:contains("Depeche Mode")').length).toBe(1)
            expect($('.breadcrumb .active:contains("Speak & Spell")').length).toBe(1)
            expect($('#music_tracks:contains("No tracks found!")').length).toBe(1)
            
      describe 'faulty tracks response', ->
        it 'it adds an error message as first row of tracks', ->
          $('#music_release_page').musicRelease()
          
          request = jasmine.Ajax.requests.at(0)
          expect(request.url).toBe('http://Volontari.at/api/v1/music/releases/2.json')
          body = """
            {
              "id": 2, "mbid":"517e51e2-cd92-4d03-b1ae-b62b0c45a77e", "spotify_id":"1YqWw5boCxSxGEkohvBvD6",
              "is_lp":true,"artist_id":1,"artist_name":"Depeche Mode","name":"Speak & Spell",
              "future_release_date":null,"released_at":"1981-10-05T00:00:00Z","listeners":251753,
              "plays":2631138,"state":"active"
            }
          """
          request.respondWith
            status: 200
            responseText: body
            
          request = jasmine.Ajax.requests.at(1)
          expect(request.url).toBe('http://Volontari.at/api/v1/music/releases/2/tracks.json')
          request.respondWith
            status: 500
            responseText: "[]"  
          
          expect($('.breadcrumb .music_artist_link:contains("Depeche Mode")').length).toBe(1)
          expect($('.breadcrumb .active:contains("Speak & Spell")').length).toBe(1)
          expect($('#music_tracks:contains("Failed to load tracks!")').length).toBe(1)
          
    describe 'faulty response', ->
      describe 'status is 404', ->
        it 'alerts an message', ->
          $('#music_release_page').musicRelease()
            
          request = jasmine.Ajax.requests.mostRecent()
          expect(request.url).toBe('http://Volontari.at/api/v1/music/releases/2.json')
          request.respondWith
            status: 404
            responseText: "{}"
          
          expect(window.alert).toHaveBeenCalledWith('Release not found!')
          
      describe 'status is other than 404', ->
        it 'alerts an message', ->
          $('#music_release_page').musicRelease()
            
          request = jasmine.Ajax.requests.mostRecent()
          expect(request.url).toBe('http://Volontari.at/api/v1/music/releases/2.json')
          request.respondWith
            status: 500
            responseText: "{}"
          
          expect(window.alert).toHaveBeenCalledWith('Failed to load release!')        
