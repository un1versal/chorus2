@Kodi.module "SongApp.List", (List, App, Backbone, Marionette, $, _) ->

  ## Single song row
  class List.Song extends App.Views.ItemView
    template: 'apps/song/list/song'
    tagName: "tr"

    initialize: ->
      duration = helpers.global.secToTime this.model.get('duration')
      menu = {'song-localadd': 'Add to playlist', 'song-download': 'Download song', 'song-localplay': 'Play in browser', 'song-musicvideo': 'Music video'}
      this.model.set({displayDuration: helpers.global.formatTime(duration), menu: menu})

    triggers:
      "click .play"            : "song:play"
      "dblclick .song-title"   : "song:play"
      "click .add"             : "song:add"
      "click .song-localadd"   : "song:localadd"
      "click .song-download"   : "song:download"
      "click .song-localplay"  : "song:localplay"
      "click .song-musicvideo" : "song:musicvideo"

    events:
      "click .dropdown > i": "populateMenu"
      "click .thumbs" : "toggleThumbs"

    populateMenu: ->
      menu = ''
      if @model.get('menu')
        for key, val of @model.get('menu')
          menu += @themeTag 'li', {class: key}, val
        this.$el.find('.dropdown-menu').html(menu)

    toggleThumbs: ->
      App.request "thumbsup:toggle:entity", @model
      this.$el.toggleClass 'thumbs-up'

    attributes: ->
      classes = ['song', 'table-row', 'can-play', 'item-' + @model.get('uid')]
      if App.request "thumbsup:check", @model
        classes.push 'thumbs-up'
      {
        class: classes.join(' ')
      }

    onShow: ->
      ## Toggle menu open class on song row.
      $('.dropdown', @$el).on 'show.bs.dropdown', =>
        @$el.addClass('menu-open')
      $('.dropdown', @$el).on 'hide.bs.dropdown', =>
        @$el.removeClass('menu-open')
      $('.dropdown', @$el).on 'click', ->
        $(@).removeClass('open').trigger('hide.bs.dropdown')

  ## Song list
  class List.Songs extends App.Views.CollectionView
    childView: List.Song
    tagName: "table"
    attributes: ->
      verbose = if @options.verbose then 'verbose' else 'basic'
      {
        class: 'songs-table table table-hover ' + verbose
      }