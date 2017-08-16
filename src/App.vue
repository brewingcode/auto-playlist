<template lang="pug">
#app
  h1 Auto Playlist
  h2.error(v-if="error") Error: {{error}}
  div(v-if="authorized")
    h3 {{authorized}}
    div
      button(@click="signOut") Sign Out
    Playlists
    h2 Tracks
    div(v-for="t in tracks")
      .track {{t.name}}
        span(v-if="t.saved")  saved!
        span(v-else)  not saved
  div(v-else)
    h3
      button(@click="auth") Authorize
</template>

<script lang="coffee">
import Playlists from './Playlists.vue'
import Spotify from './spotify.coffee'

{ log } = console

export default
  name: 'app'

  data: ->
    tracks: []
    authorized: ''
    error: ''
    pollTimer: null

  mounted: ->
    @checkAuthParams (resp) =>
      @authorized = "Hello, #{resp.id}"
      @pollTimer = setInterval =>
        @poll()
      , 5000

  methods:
    poll: ->
      @spotify 'me/player/currently-playing', (resp) =>
        track = @tracks.find (t) -> t.id is resp.item?.id
        if not track
          resp.item.progress_ms = 0
          resp.item.saved = false
          @tracks.unshift resp.item
          track = @tracks[0]

        track.progress_ms = resp.progress_ms
        progress = track.progress_ms / track.duration_ms
        log "#{track.name}: #{progress}"
        if progress > 0.90 and not track.saved
          track.saved = true
          log "would save this track: #{track.name}"
          # save track

  components: { Playlists }
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

h1, h2
  font-weight: normal

a
  color: #42b983
</style>
