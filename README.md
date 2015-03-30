# jquery-music_metadata [![Build Status](https://travis-ci.org/volontariat/jquery-music_metadata.svg?branch=master)](https://travis-ci.org/volontariat/jquery-music_metadata)

## Demo

Try it on JS Bin [here](http://jsbin.com/reqate/1/).

## Example

```html
<!DOCTYPE html>
<html>
<head>
  <script src="//code.jquery.com/jquery.min.js"></script>
  <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
  <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js"></script>
  <script src="//code.jquery.com/jquery-2.1.1.min.js"></script>
  <script src="https://rawgit.com/volontariat/jquery-music_metadata/master/app/assets/javascripts/jquery.simplePagination.js"></script>
  <script src="https://rawgit.com/volontariat/jquery-music_metadata/master/app/assets/javascripts/jquery.oembed.js"></script>
  <script src="https://rawgit.com/volontariat/jquery-music_metadata/master/jquery-music_metadata.min.js"></script>  
  <meta charset="utf-8">
</head>
<body>
  <div class="container">
    <div class="content">
      <div class="row">
        <div class="col-md-12">
          <div id="music_artists_list"></div>
        </div>
      </div>
    </div>
  </div>
  <script>
  //<![CDATA[

    $( document ).ready(function() {
      $('#music_artists_list').musicArtists();
    });

  //]]>
  </script>
</body>
</html>
```

## Music Artists List

Adds a list with music artists and pagination to the given container. A click on a music artist name replaces the container content by a music artist page.

### Example

```html
<div id="music_artists_list"></div>

<script>
  $( document ).ready(function() {
    $('#music_artists_list').musicArtists();
  });
</script>
```

## Music Artist Page

Adds a music artist page with an albums & EPs list to the given container. A click on a music release name replaces the container content by a music release page.
You have to set an http://Volontari.at - artist ID as a data attribute of the container.

### Example

```html
<div id="music_artist_page" data-artist-id="182"></div>
  
<script>
  $( document ).ready(function() {
    $('#music_artist_page').musicArtist();
  });
</script>
```

## Music Release Page

Adds a music release page with a tracks list to the given container. A click on a music track name replaces the container content by a music track page.
You have to set an http://Volontari.at - release ID as a data attribute of the container.

### Example

```html
<div id="music_release_page" data-release-id="2603"></div>
  
<script>
  $( document ).ready(function() {
    $('#music_release_page').musicRelease();
  });
</script>
```

## Music Track Page

Adds a music track page with a videos list to the given container.
You have to set an http://Volontari.at - track ID as a data attribute of the container.

### Example

```html
<div id="music_track_page" data-track-id="15942"></div>
  
<script>
  $( document ).ready(function() {
    $('#music_track_page').musicTrack();
  });
</script>
```

## Contribution

Pleae follow this screencast http://railscasts.com/episodes/300-contributing-to-open-source

To change the code of the plugin you should only change the file under app/assets/javascripts/jquery-music_metadata.js.coffee
The tests can be run after you started the Rails server and go to http://localhost:3000/specs.
Alternatively the tests can be run by this command:

```bash
RAILS_ENV=test bundle exec rake spec:javascript
```

When you're done with that then you can release the code by the following steps:

* uncompressed vanilla JavaScript: run the Rails server, view the source of root page, follow e.g. /assets/jquery-music_metadata-d9f45975fb8f6cc03de79fc32fe54488.js?body=1 and copy & paste it to /jquery-music_metadata.js in the repository
* minified JavaScript: copy & paste /jquery-music_metadata.js to http://skalman.github.io/UglifyJS-online/ and copy the minified output to /jquery-music_metadata.min.js in the repository
