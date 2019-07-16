<template lang="pug">
  #app.container-fluid.col-lg-6.col-md-9.col-sm-9.col-xs-12
    h3.error(v-if="error") Error: {{error}}
    div(v-if="playlist")
      h1 Auto Playlist: {{ playlist.name }}
      h4(v-if="playlist.description") {{ playlist.description }}
      table.table.table-striped(v-if="tracks.length")
        thead
        tbody
          tr(v-for="t in tracks" v-bind:class="t.selected ? 'success' : ''")
            td {{t.track.name}}
</template>

<script lang="coffee">
import Spotify from './spotify.coffee'
import Scroll from './scroll.coffee'
import _ from 'lodash'
import Vue from 'vue'

export default
  data: ->
    params: null
    playlist: null
    tracks: []
    error: null
    current: 0
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

</script>
