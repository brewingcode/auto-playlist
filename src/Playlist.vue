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
      table.table.table-striped.table-condensed(v-if="tracks.length")
        thead
          tr
            th.text-right(style="padding-right:2ex;") #
            th Title
            th Album
            th Spotify ID
        tbody
          tr(v-for="t,i in tracks" v-bind:class="t.selected ? 'success' : ''")
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
    current: 0
    controls: [
      [ 'j/J/down', 'next row/down one row' ]
      [ 'k/K/up', 'prev row/up one row' ]
      [ 'l/L/right', 'play track, or fast-forward if track is already playing' ]
      [ 'h/H/left', 'go back home' ]
      [ 'g', 'first row' ]
      [ 'G', 'last row' ]
      [ 'x/X', 'delete track from playlist' ]
    ]
  mixins: [ Spotify, Scroll ]
  mounted: ->
    @params = new URLSearchParams(window.location.search)
    window.addEventListener 'keydown', @onKey
    id = @params.get 'id'
    @spotify "playlists/#{id}", null, (resp) => @playlist = resp
    @spotify "playlists/#{id}/tracks", null, @allTracks
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
      if resp.next
        @spotify resp.next, null, @allTracks

    onKey: (e) ->
      if e.code in ['KeyJ', 'ArrowDown']
        @scrollDown @current + 1
      else if e.code in ['KeyK', 'ArrowUp']
        @scrollUp @current - 1
      else if e.code is 'KeyG' and e.shiftKey is false
        @scrollUp 0
        document.querySelector('body').scrollIntoView()
      else if e.code is 'KeyG' and e.shiftKey is true
        @scrollDown @tracks.length - 1
      else if e.code is 'KeyX'
        dead = @tracks[@current].track.uri
        @spotify "playlists/#{@playlist.id}/tracks",
          method: 'delete'
          data:
            tracks: [ { uri: dead } ]
        , =>
          @tracks.splice _.findIndex(@tracks, (t) -> t.track.uri is dead), 1
          @setCurrent()
      else if e.code in ['KeyL', 'ArrowRight']
        @spotify 'me/player', null, (resp) =>
          if @tracks[@current].track.id is resp.item?.id
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
                uris: [ @tracks[@current].track.uri ]
      else if e.code in ['KeyH', 'ArrowLeft']
        window.location.href = '/'

</script>
