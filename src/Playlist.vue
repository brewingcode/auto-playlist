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
          # wrapped around the bottom, scroll to very top of page
          @current = 0
          document.querySelector('body').scrollIntoView()
        else
          # check if row is below viewport, and scroll if needed
          el = document.querySelector("tr:nth-child(#{@current + 1})")
          h = window.innerHeight or document.documentElement.clientHeight
          if el?.getBoundingClientRect().bottom > h
            el.scrollIntoView(false)

      else if e.code in ['KeyK', 'ArrowUp']
        @current--
        if @current < 0
          # wrapped around the top, scroll to bottom
          @current = @tracks.length - 1
          document.querySelector('tr:last-child').scrollIntoView()
        else
          # check if the row is above viewport, and scroll if needed
          el = document.querySelector("tr:nth-child(#{@current + 1})")
          h = window.innerHeight or document.documentElement.clientHeight
          if el?.getBoundingClientRect().top < 0
            el.scrollIntoView()

      @setCurrent()

    # tell Vue about the current row
    setCurrent: ->
      @tracks.forEach (t, i) =>
        if i is @current
          t.selected = true
          @$set @tracks, i, t
        else if t.selected is true
          t.selected = false
          @$set @tracks, i, t

</script>
