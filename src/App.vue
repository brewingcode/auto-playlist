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
      @pollTimer = setTimeout @poll.bind(this), 0

  methods:
    poll: ->
      @spotify 'me/player/currently-playing', (resp) =>
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
            log "would save this track: #{track.item.name}"
            # save track

        @pollTimer = setTimeout @poll.bind(this), 5000

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
