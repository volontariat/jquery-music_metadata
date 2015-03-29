describe 'MusicMetadata.Artists', ->
  beforeEach ->
    jasmine.Ajax.install()
    affix '#music_artists_list'
    jasmine.Ajax.requests.reset()
    
  describe '#showPage', ->
    describe 'successful response', ->  
      describe 'any artists', ->
        it 'adds rows to the table with artist metadata', ->
          $('#music_artists_list').musicArtists()
          
          request = jasmine.Ajax.requests.mostRecent()
          expect(request.url).toBe('http://Volontari.at/api/v1/music/artists.json?state=active&page=1')
          body = """
            {
              "current_page": 1, "per_page": 10, "total_entries": 1, "total_pages": 1,
              "entries": [
                {
                  "id": 1, "mbid": "x", "name": "Dummy", "disambiguation": "Dummy", "listeners": 78616, "plays": 3033578,
                  "founded_at": "2010-01-01T00:00:00Z", "dissolved_at": null, "state": "active"
                }
              ]
            }
          """
          request.respondWith
            status: 200
            responseText: body
          
          expect($($('.music_artist_link')[0]).data('id')).toBe(1)
      
      describe 'no artists', ->
        it 'adds a row to the table with the error message', ->
          $('#music_artists_list').musicArtists()
          
          request = jasmine.Ajax.requests.mostRecent()
          expect(request.url).toBe('http://Volontari.at/api/v1/music/artists.json?state=active&page=1')
          body = """
            {
              "current_page": 1, "per_page": 10, "total_entries": 1, "total_pages": 1,
              "entries": []
            }
          """
          request.respondWith
            status: 200
            responseText: body
          
          expect($('#music_artists_list:contains("No artists found!")').length).toBe(1)
            
    describe 'faulty response', ->  
      it 'adds rows to the table with an error message', -> 
        $('#music_artists_list').musicArtists()
        
        request = jasmine.Ajax.requests.mostRecent()
        expect(request.url).toBe('http://Volontari.at/api/v1/music/artists.json?state=active&page=1')
        request.respondWith
          status: 500
          responseText: ''
        
        expect($("td:contains('Failed to load artists!')").length).toBe(1)
      
