(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  (function($, window) {
    var Artist, Artists, Base, MusicMetadata, Release, Track;
    MusicMetadata = {};
    MusicMetadata.Base = Base = (function() {
      Base.prototype.defaults = {
        host: 'http://Volontari.at'
      };

      function Base(el, options) {
        if (el) {
          this.init(el, options);
        }
      }

      Base.prototype.init = function(el, options) {
        this.options = $.extend({}, this.defaults, options);
        this.$el = $(el);
        return $.data(el, this.constructor.prototype.jqueryInstanceMethodName, this);
      };

      return Base;

    })();
    MusicMetadata.Artists = Artists = (function(superClass) {
      extend(Artists, superClass);

      function Artists() {
        return Artists.__super__.constructor.apply(this, arguments);
      }

      Artists.prototype.jqueryInstanceMethodName = 'musicArtists';

      Artists.prototype.init = function(el, options) {
        Artists.__super__.init.call(this, el, options);
        return this.showHeadAndPage(1);
      };

      Artists.prototype.showHeadAndPage = function(pageNumber) {
        var tableHtml;
        tableHtml = "<table class=\"table table-striped\">\n  <thead>\n    <tr class=\"odd\">\n      <th style=\"width: 300px;\">Name</th>\n      <th>Disambiguation</th>\n      <th style=\"width: 75px;\">Founded at</th>\n      <th style=\"width: 75px;\">Dissolved at</th>\n      <th style=\"width: 75px;\">Listeners</th>\n    </tr>\n  </thead>\n  <tbody>\n    <tr>\n      <td colspan=\"4\" style=\"background-color:white;\">\n        <img src=\"https://i1.wp.com/cdnjs.cloudflare.com/ajax/libs/galleriffic/2.0.1/css/loader.gif\" style=\"width:16px; height:16px;\"/>\n      </td>\n    </tr>\n  </tbody>\n</table> \n<nav>\n  <ul class=\"pagination\">\n  </ul>\n</nav>";
        this.$el.html(tableHtml);
        return this.showPage(pageNumber, true);
      };

      Artists.prototype.showPage = function(pageNumber, init_pagination) {
        this.$el.data('current-page', pageNumber);
        return $.ajax({
          url: this.options['host'] + "/api/v1/music/artists.json?state=active&page=" + pageNumber,
          type: 'GET',
          dataType: 'json',
          success: (function(_this) {
            return function(data) {
              var rowHtml;
              _this.$el.find('tbody').empty();
              if (data['entries'].length === 0) {
                rowHtml = "<tr>\n  <td colspan=\"4\" style=\"background-color:white;\">\n    No artists found!\n  </td>\n</tr>";
                return _this.$el.find('tbody').html(rowHtml);
              } else {
                $.each(data['entries'], function(index, artist) {
                  $.each(artist, function(attribute, value) {
                    var date;
                    switch (attribute) {
                      case 'founded_at':
                      case 'dissolved_at':
                        if (value === null) {
                          return artist[attribute] = '';
                        } else {
                          date = new Date(value);
                          return artist[attribute] = date.toLocaleDateString();
                        }
                        break;
                      default:
                        if (value === null) {
                          return artist[attribute] = '';
                        }
                    }
                  });
                  rowHtml = "<tr class=\"even\">\n  <td style=\"width: 300px;\"><a class=\"music_artist_link\" href=\"#\" data-id=\"" + artist['id'] + "\">" + artist['name'] + "</a></td>\n  <td>" + artist['disambiguation'] + "</td>\n  <td style=\"width: 75px\">" + artist['founded_at'] + "</td>\n  <td style=\"width: 75px\">" + artist['dissolved_at'] + "</td>\n  <td style=\"width: 75px\">" + artist['listeners'] + "</td>\n</tr>";
                  return _this.$el.find('tbody').append(rowHtml);
                });
                _this.$el.find('.music_artist_link').on('click', function() {
                  var lastPage;
                  lastPage = _this.$el.data('current-page');
                  _this.$el.data('artist-id', $(event.target).data('id'));
                  _this.$el.data('last-artists-page', lastPage);
                  return _this.$el.musicArtist('showMetadata');
                });
                if (init_pagination) {
                  return _this.$el.find('.pagination').pagination({
                    items: data['total_entries'],
                    itemsOnPage: data['per_page'],
                    currentPage: data['current_page'],
                    onPageClick: function(pageNumber, event) {
                      return _this.showPage(pageNumber, false);
                    }
                  });
                }
              }
            };
          })(this),
          error: (function(_this) {
            return function(data) {
              var rowHtml;
              rowHtml = "<tr>\n  <td colspan=\"4\" style=\"background-color:white;\">\n    Failed to load artists!\n  </td>\n</tr>";
              return _this.$el.find('tbody').html(rowHtml);
            };
          })(this)
        });
      };

      return Artists;

    })(MusicMetadata.Base);
    MusicMetadata.Artist = Artist = (function(superClass) {
      extend(Artist, superClass);

      function Artist() {
        return Artist.__super__.constructor.apply(this, arguments);
      }

      Artist.prototype.jqueryInstanceMethodName = 'musicArtist';

      Artist.prototype.init = function(el, options) {
        Artist.__super__.init.call(this, el, options);
        return this.showMetadata();
      };

      Artist.prototype.showMetadata = function() {
        return $.ajax({
          url: this.options['host'] + "/api/v1/music/artists/" + (this.$el.data('artist-id')) + ".json",
          type: 'GET',
          dataType: 'json',
          success: (function(_this) {
            return function(data) {
              var pageHtml;
              pageHtml = "<ol class=\"breadcrumb\">\n  <li><a class=\"music_artists_link\" href=\"#\">Artists</a></li>\n  <li class=\"active\">" + data['name'] + "</li>\n</ol>\n\n<h2>Albums & EPs</h2>\n\n<table id=\"music_releases\" class=\"table table-striped\">\n  <thead>\n    <tr class=\"odd\">\n      <th style=\"width: 100px\">Released at</th>\n      <th>Name</th>\n      <th style=\"width: 75px\">Type</th>\n      <th style=\"width: 75px\">Listeners</th>\n    </tr>\n  </thead>\n  <tbody>\n    <tr>\n      <td colspan=\"4\" style=\"background-color:white;\">\n        <img src=\"https://i1.wp.com/cdnjs.cloudflare.com/ajax/libs/galleriffic/2.0.1/css/loader.gif\" style=\"width:16px; height:16px;\"/>\n      </td>\n    </tr>\n  </tbody>\n</table> ";
              _this.$el.html(pageHtml);
              _this.$el.find('.music_artists_link').on('click', function() {
                if (_this.$el.data('musicArtists')) {
                  return _this.$el.musicArtists('showHeadAndPage', _this.$el.data('last-artists-page') || 1);
                } else {
                  return _this.$el.musicArtists();
                }
              });
              return _this.showReleases();
            };
          })(this),
          error: (function(_this) {
            return function(data) {
              if (data.status === 404) {
                return alert('Artist not found!');
              } else {
                return alert('Failed to load artist!');
              }
            };
          })(this)
        });
      };

      Artist.prototype.showReleases = function() {
        return $.ajax({
          url: this.options['host'] + "/api/v1/music/artists/" + (this.$el.data('artist-id')) + "/releases.json",
          type: 'GET',
          dataType: 'json',
          success: (function(_this) {
            return function(data) {
              var rowHtml;
              $('#music_releases tbody').empty();
              if (data.length === 0) {
                rowHtml = "<tr>\n  <td colspan=\"4\" style=\"background-color:white;\">No releases found!</td>\n</tr>";
                return $('#music_releases tbody').html(rowHtml);
              } else {
                $.each(data, function(index, release) {
                  var type;
                  $.each(release, function(attribute, value) {
                    var date;
                    if (value === null) {
                      return release[attribute] = '';
                    } else {
                      switch (attribute) {
                        case 'released_at':
                          if (release['future_release_date'] !== null && release['future_release_date'] !== '') {
                            return release[attribute] = release['future_release_date'];
                          } else {
                            date = new Date(value);
                            return release[attribute] = date.toLocaleDateString();
                          }
                      }
                    }
                  });
                  type = release['is_lp'] ? 'Album' : 'EP';
                  rowHtml = "<tr class=\"even\">\n  <td style=\"width: 100px\">" + release['released_at'] + "</td>\n  <td><a class=\"music_release_link\" href=\"#\" data-id=\"" + release['id'] + "\">" + release['name'] + "</a></td>\n  <td style=\"width: 75px\">" + type + "</td>\n  <td style=\"width: 75px\">" + release['listeners'] + "</td>\n</tr>";
                  return $('#music_releases tbody').append(rowHtml);
                });
                return _this.$el.find('.music_release_link').on('click', function() {
                  _this.$el.removeData('musicRelease');
                  _this.$el.data('release-id', $(event.target).data('id'));
                  if (_this.$el.data('musicRelease')) {
                    return _this.$el.musicRelease('showMetadata');
                  } else {
                    return _this.$el.musicRelease();
                  }
                });
              }
            };
          })(this),
          error: (function(_this) {
            return function(data) {
              var rowHtml;
              rowHtml = "<tr>\n  <td colspan=\"4\" style=\"background-color:white;\">\n    Failed to load releases!\n  </td>\n</tr>";
              return $('#music_releases tbody').html(rowHtml);
            };
          })(this)
        });
      };

      return Artist;

    })(MusicMetadata.Base);
    MusicMetadata.Release = Release = (function(superClass) {
      extend(Release, superClass);

      function Release() {
        return Release.__super__.constructor.apply(this, arguments);
      }

      Release.prototype.jqueryInstanceMethodName = 'musicRelease';

      Release.prototype.init = function(el, options) {
        Release.__super__.init.call(this, el, options);
        return this.showMetadata();
      };

      Release.prototype.showMetadata = function() {
        return $.ajax({
          url: this.options['host'] + "/api/v1/music/releases/" + (this.$el.data('release-id')) + ".json",
          type: 'GET',
          dataType: 'json',
          success: (function(_this) {
            return function(data) {
              var pageHtml;
              pageHtml = "<ol class=\"breadcrumb\">\n  <li><a class=\"music_artists_link\" href=\"#\">Artists</a></li>\n  <li><a class=\"music_artist_link\" href=\"#\" data-id=\"" + data['artist_id'] + "\">" + data['artist_name'] + "</a></li>\n  <li class=\"active\">" + data['name'] + "</li>\n</ol>\n\n<h2>Tracks</h2>\n\n<table id=\"music_tracks\" class=\"table table-striped\">\n  <thead>\n    <tr class=\"odd\">\n      <th style=\"width: 50px\">Nr</th>\n      <th>Name</th>\n      <th style=\"width: 75px\">Duration</th>\n      <th style=\"width: 75px\">Listeners</th>\n    </tr>\n  </thead>\n  <tbody>\n    <tr>\n      <td colspan=\"4\" style=\"background-color:white;\">\n        <img src=\"https://i1.wp.com/cdnjs.cloudflare.com/ajax/libs/galleriffic/2.0.1/css/loader.gif\" style=\"width:16px; height:16px;\"/>\n      </td>\n    </tr>\n  </tbody>\n</table> ";
              _this.$el.html(pageHtml);
              _this.$el.find('.music_artists_link').on('click', function() {
                if (_this.$el.data('musicArtists')) {
                  return _this.$el.musicArtists('showHeadAndPage', _this.$el.data('last-artists-page') || 1);
                } else {
                  return _this.$el.musicArtists();
                }
              });
              _this.$el.find('.music_artist_link').on('click', function() {
                _this.$el.data('artist-id', $(event.target).data('id'));
                if (_this.$el.data('musicArtist')) {
                  return _this.$el.musicArtist('showMetadata');
                } else {
                  return _this.$el.musicArtist();
                }
              });
              return _this.showTracks();
            };
          })(this),
          error: (function(_this) {
            return function(data) {
              if (data.status === 404) {
                return alert('Release not found!');
              } else {
                return alert('Failed to load release!');
              }
            };
          })(this)
        });
      };

      Release.prototype.showTracks = function() {
        return $.ajax({
          url: this.options['host'] + "/api/v1/music/releases/" + (this.$el.data('release-id')) + "/tracks.json",
          type: 'GET',
          dataType: 'json',
          success: (function(_this) {
            return function(data) {
              var rowHtml;
              $('#music_tracks tbody').empty();
              if (data.length === 0) {
                rowHtml = "<tr>\n  <td colspan=\"4\" style=\"background-color:white;\">No tracks found!</td>\n</tr>";
                return $('#music_tracks tbody').html(rowHtml);
              } else {
                $.each(data, function(index, track) {
                  $.each(track, function(attribute, value) {
                    if (value === null) {
                      return track[attribute] = '';
                    }
                  });
                  rowHtml = "<tr class=\"even\">\n  <td style=\"width: 50px; text-align:right;\">" + track['nr'] + "</td>\n  <td><a class=\"music_track_link\" href=\"#\" data-id=\"" + track['id'] + "\">" + track['name'] + "</a></td>\n  <td style=\"width: 75px;\">" + track['duration'] + "</td>\n  <td style=\"width: 75px;\">" + track['listeners'] + "</td>\n</tr>";
                  return $('#music_tracks tbody').append(rowHtml);
                });
                return _this.$el.find('.music_track_link').on('click', function() {
                  _this.$el.data('track-id', $(event.target).data('id'));
                  if (_this.$el.data('musicTrack')) {
                    return _this.$el.musicTrack('showMetadata');
                  } else {
                    return _this.$el.musicTrack();
                  }
                });
              }
            };
          })(this),
          error: (function(_this) {
            return function(data) {
              var rowHtml;
              rowHtml = "<tr>\n  <td colspan=\"4\" style=\"background-color:white;\">\n    Failed to load tracks!\n  </td>\n</tr>";
              return _this.$el.find('tbody').html(rowHtml);
            };
          })(this)
        });
      };

      return Release;

    })(MusicMetadata.Base);
    MusicMetadata.Track = Track = (function(superClass) {
      extend(Track, superClass);

      function Track() {
        return Track.__super__.constructor.apply(this, arguments);
      }

      Track.prototype.jqueryInstanceMethodName = 'musicTrack';

      Track.prototype.init = function(el, options) {
        Track.__super__.init.call(this, el, options);
        return this.showMetadata();
      };

      Track.prototype.showMetadata = function() {
        return $.ajax({
          url: this.options['host'] + "/api/v1/music/tracks/" + (this.$el.data('track-id')) + ".json",
          type: 'GET',
          dataType: 'json',
          success: (function(_this) {
            return function(data) {
              var pageHtml;
              pageHtml = "<ol class=\"breadcrumb\">\n  <li><a class=\"music_artists_link\" href=\"#\">Artists</a></li>\n  <li><a class=\"music_artist_link\" href=\"#\" data-id=\"" + data['artist_id'] + "\">" + data['artist_name'] + "</a></li>\n  <li><a class=\"music_release_link\" href=\"#\" data-id=\"" + data['release_id'] + "\">" + data['release_name'] + "</a></li>\n  <li class=\"active\">" + data['name'] + "</li>\n</ol>\n\n<h2>Videos</h2>\n\n<div id=\"music_videos\">\n  <img src=\"https://i1.wp.com/cdnjs.cloudflare.com/ajax/libs/galleriffic/2.0.1/css/loader.gif\" style=\"width:16px; height:16px;\"/>\n</div>";
              _this.$el.html(pageHtml);
              _this.$el.find('.music_artists_link').on('click', function() {
                if (_this.$el.data('musicArtists')) {
                  return _this.$el.musicArtists('showHeadAndPage', _this.$el.data('last-artists-page') || 1);
                } else {
                  return _this.$el.musicArtists();
                }
              });
              _this.$el.find('.music_artist_link').on('click', function() {
                _this.$el.data('artist-id', $(event.target).data('id'));
                if (_this.$el.data('musicArtist')) {
                  return _this.$el.musicArtist('showMetadata');
                } else {
                  return _this.$el.musicArtist();
                }
              });
              _this.$el.find('.music_release_link').on('click', function() {
                _this.$el.data('release-id', $(event.target).data('id'));
                if (_this.$el.data('musicRelease')) {
                  return _this.$el.musicRelease('showMetadata');
                } else {
                  return _this.$el.musicRelease();
                }
              });
              return _this.showVideos();
            };
          })(this),
          error: (function(_this) {
            return function(data) {
              if (data.status === 404) {
                return alert('Track not found!');
              } else {
                return alert('Failed to load track!');
              }
            };
          })(this)
        });
      };

      Track.prototype.showVideos = function() {
        return $.ajax({
          url: this.options['host'] + "/api/v1/music/tracks/" + (this.$el.data('track-id')) + "/videos.json",
          type: 'GET',
          dataType: 'json',
          success: (function(_this) {
            return function(data) {
              $('#music_videos').empty();
              if (data.length === 0) {
                return $('#music_videos').html('No videos available!');
              } else {
                $.each(data, function(index, video) {
                  var rowHtml;
                  $.each(video, function(attribute, value) {
                    if (value === null) {
                      return video[attribute] = '';
                    }
                  });
                  rowHtml = "<h3>" + video['artist_name'] + " – " + video['track_name'] + " (" + video['status'] + ")</h3>\n<p>\n  <a href=\"" + video['url'] + "\" class=\"oembed\"></a>\n</p>";
                  return $('#music_videos').append(rowHtml);
                });
                return $('#music_videos .oembed').oembed();
              }
            };
          })(this),
          error: (function(_this) {
            return function(data) {
              var rowHtml;
              rowHtml = "<tr>\n  <td colspan=\"4\" style=\"background-color:white;\">Failed to load videos!</td>\n</tr>";
              return $('#music_videos').html(rowHtml);
            };
          })(this)
        });
      };

      return Track;

    })(MusicMetadata.Base);
    $.pluginFactory = function(plugin) {
      return $.fn[plugin.prototype.jqueryInstanceMethodName] = function(options) {
        var after, args;
        args = $.makeArray(arguments);
        after = args.slice(1);
        return this.each(function() {
          var instance;
          instance = $.data(this, plugin.prototype.jqueryInstanceMethodName);
          if (instance) {
            if (typeof options === 'string') {
              return instance[options].apply(instance, after);
            } else if (instance.update) {
              return instance.update.apply(instance, args);
            }
          } else {
            return new plugin(this, options);
          }
        });
      };
    };
    $.pluginFactory(MusicMetadata.Artists);
    $.pluginFactory(MusicMetadata.Artist);
    $.pluginFactory(MusicMetadata.Release);
    return $.pluginFactory(MusicMetadata.Track);
  })(window.jQuery, window);

}).call(this);
