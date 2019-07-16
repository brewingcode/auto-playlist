<template lang="pug">
  #app.container-fluid
    div
      a(href="/") back to home
      h3 Controls (ala vim)
      table.table-striped.controls
        thead
          tr
            th Key(s)
            th.text-center Action
        tbody
          tr(v-for="c in controls")
            td(style="font-family:monospace; padding-right:3ex;") {{c[0]}}
            td.text-center {{c[1]}}

    h3.error(v-if="error") Error: {{error}}
    div(v-if="playlist")
      h1 Auto Playlist: {{ playlist.name }}
      h4(v-if="playlist.description") {{ playlist.description }}
      table.table.table-striped.table-condensed.tracks(v-if="tracks.length")
        thead
          tr
            th.text-right(style="padding-right:2ex;") #
            th Title
            th Album
            th Spotify ID
        tbody
          tr(v-for="t,i in tracks" v-bind:class="{ success: t.selected, dupe: t.duplicate }")
            td.text-right(style="padding-right:2ex;") {{i+1}}
            td.text-left {{t.track.name}}
            td.text-left {{t.track.album.name}}
            td(style="font-family:monospace") {{t.track.id}}
</template>

<script lang="coffee">
import Spotify from './mixins/spotify.coffee'
import Scroll from './mixins/scroll.coffee'
import _ from 'lodash'
import Vue from 'vue'

export default
  data: ->
    params: null
    playlist: null
    tracks: []
    error: null
    selectedIndex: 0
    controls: [
      [ 'j/down', 'next row/down one row' ]
      [ 'k/up', 'prev row/up one row' ]
      [ 'l/right', 'play track, or fast-forward if track is already playing' ]
      [ 'h/left', 'go back home' ]
      [ 'g', 'first row' ]
      [ 'G', 'last row' ]
      [ 'x', 'delete track from playlist' ]
    ]
  mixins: [ Spotify, Scroll ]
  mounted: ->
    @params = new URLSearchParams(window.location.search)
    id = @params.get 'id'
    @spotify "playlists/#{id}", null, (resp) => @playlist = resp
    @spotify "playlists/#{id}/tracks", null, @allTracks
    if not window.playlist_keybind
      window.playlist_keybind = 1
      window.addEventListener 'keydown', @onKey
  computed:
    tracklist: -> _.sortBy @tracks, 'added_at'
  methods:
    allTracks: (resp) ->
      if resp.items.length is 0
        @error = 'No tracks found in playlist'
        return
      resp.items.forEach (i) -> i.selected = false
      if @tracks.length is 0
        resp.items[0].selected = true
      @tracks.push resp.items...
      @markDuplicates()
      if resp.next
        @spotify resp.next, null, @allTracks

    markDuplicates: ->
      history = {}
      @tracks.forEach (t) ->
        key = t.track.name + t.track.artists[0].name
        if history[key]
          t.duplicate = true
        else
          history[key] = 1
          t.duplicate = false

    onKey: (e) ->
      if e.key in ['j', 'ArrowDown']
        @scrollDown @selectedIndex + 1
      else if e.key in ['k', 'ArrowUp']
        @scrollUp @selectedIndex - 1
      else if e.key is 'g'
        @scrollUp 0
        document.querySelector('body').scrollIntoView()
      else if e.key is 'G'
        @scrollDown @tracks.length - 1
      else if e.key is 'x'
        dead = @tracks[@selectedIndex].track.uri
        @spotify "playlists/#{@playlist.id}/tracks",
          method: 'delete'
          data:
            tracks: [ { uri: dead } ]
        , =>
          @tracks.splice _.findIndex(@tracks, (t) -> t.track.uri is dead), 1
          @setCurrent()
      else if e.key in ['l', 'ArrowRight']
        @spotify 'me/player', null, (resp) =>
          if @tracks[@selectedIndex].track.id is resp.item?.id
            # currently playing, skip forward 30 seconds
            seekTo = resp.progress_ms + 30000
            @spotify 'me/player/seek',
              method: 'put'
              params:
                position_ms: seekTo
          else
            # not the currently playing track, start playing it
            @spotify 'me/player/play',
              method: 'put'
              data:
                uris: [ @tracks[@selectedIndex].track.uri ]
      else if e.key in ['h', 'ArrowLeft']
        window.location.href = '/'

</script>

<style lang="stylus">
tr.dupe
  color: red
</style>
