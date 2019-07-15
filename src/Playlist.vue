<template lang="pug">
  #app.container-fluid.col-lg-6.col-md-9.col-sm-9.col-xs-12
    h3.error(v-if="error") Error: {{error}}
    div(v-if="playlist" v-on:click="onKey")
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
import _ from 'lodash'
import Vue from 'vue'

export default
  data: ->
    params: null
    playlist: null
    tracks: []
    error: null
    current: -1
  mixins: [ Spotify ]
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
      @tracks.push resp.items...
      if resp.next
        @spotify resp.next, null, @allTracks
    onKey: (e) ->
      if e.code in ['KeyJ', 'ArrowDown']
        @current++
        if @current > @tracks.length - 1
          @current = 0
          document.querySelector('tr:first-child').scrollIntoView()
      else if e.code in ['KeyK', 'ArrowUp']
        @current--
        if @current < 0
          @current = @tracks.length - 1
          document.querySelector('tr:last-child').scrollIntoView()
      @setCurrent()

    setCurrent: ->
      @tracks.forEach (t, i) =>
        if i is @current
          t.selected = true
          @$set @tracks, i, t
        else if t.selected is true
          t.selected = false
          @$set @tracks, i, t

</script>
