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
    div(v-if="playlist")
      h2 Currently playing:
      div
        div(v-if="current && current.is_playing")
          SpotifyTrack(:t="current")
        div(v-else) (nothing)
      div(v-if="history.length")
        h2 Previously played:
        div(v-for="t in history")
          SpotifyTrack(:t="t")
  div(v-else)
    h3
      button(@click="auth") Authorize
</template>

<script lang="coffee">
import Spotify from './spotify.coffee'
import vSelect from 'vue-select'
import SpotifyTrack from './Track.vue' # "track" is a reserved html5 tag name

{ log } = console

export default
  name: 'app'

  data: ->
    playlist: null
    playlists: []
    current: null
    history: []
    authorized: null
    error: null

  mounted: ->
    @fromStore()
    @checkAuthParams (resp) =>
      @authorized = resp
      setTimeout @poll.bind(this), 0
      @spotify 'me/playlists', null, (resp) =>
        @playlists = resp.items?.map (item) ->
          value: item.id
          label: item.name

  methods:
    toStore: ->
      for k in ['current', 'playlist', 'history']
        if this[k]
          try
            @$localStorage.set k, JSON.stringify this[k]

    fromStore: ->
      for k in ['current', 'playlist', 'history']
        if v = @$localStorage.get k
          try
            this[k] = JSON.parse v

    save: ->
      if @current.is_playing and (not @current.saved) and @playlist
        log "saving #{@current.item.name} to #{@playlist.label}"
        @spotify "users/#{@authorized.id}/playlists/#{@playlist.value}/tracks",
          uris: [@current.item.uri]
        , (resp) =>
          console.log 'playlist saved:', resp
          @current.saved = true

    poll: ->
      @spotify 'me/player/currently-playing', null, (resp) =>
        if @current and @current.item.id isnt resp.item.id
          @history.unshift @current
          resp.saved = false
          @current = resp

        unless @current
          resp.saved = false
          @current = resp

        @current[k] = resp[k] for k in ['is_playing', 'progress_ms']
        progress = @current.progress_ms / @current.item.duration_ms
        log "#{@current.item.name}: #{progress}"
        if progress > 0.90
          @save()

        @toStore()
        setTimeout @poll.bind(this), 5000

  components: { vSelect, SpotifyTrack }
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
