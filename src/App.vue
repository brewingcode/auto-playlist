<template lang="pug">
#app
  h1 Auto Playlist
  h2.error(v-if="error") Error: {{error}}
  div(v-if="authorized")
    h3 Hello, {{authorized.id}}
    div
      button(@click="signOut") Sign Out
    .playlists
      h3 Pick one of your playlists
      v-select(v-model="playlist", :options="playlists")
    h2 Tracks
    div
      div(v-if="tracks.length && !tracks[0].is_playing")
        .track (no track currently playing)
      div(v-for="t in tracks")
        .track {{t.item.name}}
          span(v-if="t.saved")  saved!
          span(v-else)  not saved
  div(v-else)
    h3
      button(@click="auth") Authorize
</template>

<script lang="coffee">
import Spotify from './spotify.coffee'
import vSelect from 'vue-select'

{ log } = console

export default
  name: 'app'

  data: ->
    playlist: null
    playlists: []
    tracks: []
    authorized: null
    error: null
    pollTimer: null

  mounted: ->
    try
      tracks = JSON.parse(@$localStorage.get 'tracks')
      if tracks and tracks.length
        @tracks = tracks
    @checkAuthParams (resp) =>
      @authorized = resp
      @pollTimer = setTimeout @poll.bind(this), 0
      @spotify 'me/playlists', null, (resp) =>
        @playlists = resp.items?.map (item) ->
          value: item.id
          label: item.name

  methods:
    poll: ->
      @spotify 'me/player/currently-playing', null, (resp) =>
        track = @tracks.find (t) -> t.item.id is resp.item?.id
        if not track
          track = resp
          track.saved = false
          @tracks.unshift track

        for k in ['is_playing', 'progress_ms']
          track[k] = resp[k]

        if track.is_playing
          progress = track.progress_ms / track.item.duration_ms
          log "#{track.item.name}: #{progress}"
          if progress > 0.90 and not track.saved
            track.saved = true
            log "would save #{track.item.name} to #{@playlist.label}"
            # save track

        @$localStorage.set 'tracks', JSON.stringify(@tracks)
        @pollTimer = setTimeout @poll.bind(this), 5000

  components: { vSelect }
  mixins: [ Spotify ]
</script>

<style lang="stylus">
#app
  font-family: 'Avenir', Helvetica, Arial, sans-serif
  -webkit-font-smoothing: antialiased
  -moz-osx-font-smoothing: grayscale
  text-align: center
  color: #2c3e50
  margin-top: 60px

.playlists
  width: 30em
  display: inline-block

h1, h2
  font-weight: normal

a
  color: #42b983
</style>
