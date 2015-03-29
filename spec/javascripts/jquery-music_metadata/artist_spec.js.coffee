describe 'MusicMetadata.Artist', ->
  beforeEach ->
    jasmine.Ajax.install()
    window.alert = jasmine.createSpy()
    affix '#music_artist_page[data-artist-id="1"]'
    jasmine.Ajax.requests.reset()
  
  describe '#showMetadata and #showReleases', ->
    describe 'successful response', -> 
      describe 'successful releases response', ->
        describe 'with releases', -> 
          it 'adds a breadcrumb with the artist name and list with 1 release', ->
            $('#music_artist_page').musicArtist()
            
            request = jasmine.Ajax.requests.at(0)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/artists/1.json')
            body = """
              {
                "id": 1, "mbid": "x", "name": "Dummy", "disambiguation": "Dummy", "listeners": 78616, "plays": 3033578,
                "founded_at": "2010-01-01T00:00:00Z", "dissolved_at": null, "state": "active"
              }
            """
            request.respondWith
              status: 200
              responseText: body
              
            request = jasmine.Ajax.requests.at(1)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/artists/1/releases.json')
            body = """
              [
                {
                  "id": 2, "mbid": "517e51e2-cd92-4d03-b1ae-b62b0c45a77e", "spotify_id": "1YqWw5boCxSxGEkohvBvD6",
                  "is_lp": true, "artist_id": 1, "artist_name": "Depeche Mode", "name": "Speak & Spell",
                  "future_release_date": null, "released_at": "1981-10-05T00:00:00Z", "listeners": 251753,
                  "plays": 2631138, "state": "active"
                }
              ]
            """
            request.respondWith
              status: 200
              responseText: body  
            
            expect($(".breadcrumb .active:contains('Dummy')").length).toBe(1)
            expect($('#music_releases .music_release_link:contains("Speak & Spell")').length).toBe(1)
            
        describe 'without releases', ->
          it 'adds a breadcrumb including the artist name and list including an error message', ->
            $('#music_artist_page').musicArtist()
            
            request = jasmine.Ajax.requests.at(0)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/artists/1.json')
            body = """
              {
                "id": 1, "mbid": "x", "name": "Dummy", "disambiguation": "Dummy", "listeners": 78616, "plays": 3033578,
                "founded_at": "2010-01-01T00:00:00Z", "dissolved_at": null, "state": "active"
              }
            """
            request.respondWith
              status: 200
              responseText: body
              
            request = jasmine.Ajax.requests.at(1)
            expect(request.url).toBe('http://Volontari.at/api/v1/music/artists/1/releases.json')
            request.respondWith
              status: 200
              responseText: "[]"  
            
            expect($(".breadcrumb .active:contains('Dummy')").length).toBe(1)
            expect($('#music_releases:contains("No releases found!")').length).toBe(1)
        
      describe 'faulty releases response', ->
        it 'shows an error message in the releases list', ->
          $('#music_artist_page').musicArtist()
          
          request = jasmine.Ajax.requests.at(0)
          expect(request.url).toBe('http://Volontari.at/api/v1/music/artists/1.json')
          body = """
            {
              "id": 1, "mbid": "x", "name": "Dummy", "disambiguation": "Dummy", "listeners": 78616, "plays": 3033578,
              "founded_at": "2010-01-01T00:00:00Z", "dissolved_at": null, "state": "active"
            }
          """
          request.respondWith
            status: 200
            responseText: body
            
          request = jasmine.Ajax.requests.at(1)
          expect(request.url).toBe('http://Volontari.at/api/v1/music/artists/1/releases.json')
          request.respondWith
            status: 500
            responseText: "{}" 
          
          expect($(".breadcrumb .active:contains('Dummy')").length).toBe(1)
          expect($('#music_releases:contains("Failed to load releases!")').length).toBe(1)
        
    describe 'faulty response', ->  
      describe 'status is 404', ->
        it 'alerts a message', ->
          $('#music_artist_page').musicArtist()
          
          request = jasmine.Ajax.requests.mostRecent()
          expect(request.url).toBe('http://Volontari.at/api/v1/music/artists/1.json')
          request.respondWith
            status: 404
            responseText: ""
          
          expect(window.alert).toHaveBeenCalledWith('Artist not found!')
        
      describe 'status is other than 404', ->
        it 'alerts a message', ->
          $('#music_artist_page').musicArtist()
          
          request = jasmine.Ajax.requests.mostRecent()
          expect(request.url).toBe('http://Volontari.at/api/v1/music/artists/1.json')
          request.respondWith
            status: 500
            responseText: ""
          
          expect(window.alert).toHaveBeenCalledWith('Failed to load artist!')