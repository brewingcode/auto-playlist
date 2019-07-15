<template lang="pug">
  #app.container-fluid.col-lg-6.col-md-9.col-sm-9.col-xs-12(v-if="playlist")
    h1 Auto Playlist: {{ playlist.name }}
    h4(v-if="playlist.description") {{ playlist.description }}
    h3.error(v-if="error") Error: {{error}}
    table.table.table-striped(v-if="tracks")
      thead
      tbody
        tr(v-for="t in tracklist")
          td {{t.track.name}}
</template>

<script lang="coffee">
import Spotify from './spotify.coffee'
import _ from 'lodash'

export default
  data: ->
    params: null
    playlist: null
    tracks: null
    error: null
  mixins: [ Spotify ]
  mounted: ->
    @params = new URLSearchParams(window.location.search)
    id = @params.get 'id'
    @spotify "playlists/#{id}", null, (resp) => @playlist = resp
    @spotify "playlists/#{id}/tracks", null, (resp) => @tracks = resp
  computed:
    tracklist: -> _.sortBy @tracks.items, 'added_at'

</script>

