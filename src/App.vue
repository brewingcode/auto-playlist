<template lang="pug">
#app.container-fluid.col-lg-6.col-md-9.col-sm-9.col-xs-12
  h1 Auto Playlist
  h3.error(v-if="error") Error: {{error}}
  div(v-if="authorized")
    h4 Hello, {{authorized.id}}
    div
      button(@click="signOut") Sign Out
    .playlists
      h3 Destination playlist
      v-select(v-model="playlist", :options="playlists", :on-change="playlistChange")
    div(v-if="playlist")
      h2 Currently playing:
      div
        div(v-if="current && current.is_playing")
          SpotifyTrack.current(:t="current")
        div(v-else) (nothing)
      div(v-if="history.length")
        h3 Previously played:
        div(v-for="t in history")
          SpotifyTrack(:t="t")
    .usage(v-else).
      Any track that you listen to more than 90% of will automatically be
      added to the end of your selected playlist.
  div(v-else)
    button(@click="auth") Authorize
  div
    hr
    a(href="https://github.com/brewingcode/auto-playlist") View on github.com
</template>

<script lang="coffee">
import Spotify from './spotify.coffee'
import vSelect from 'vue-select'
import SpotifyTrack from './Track.vue' # "track" is a reserved html5 tag name

export default
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
      @spotify 'me/playlists', null, (resp) =>
        setTimeout @poll.bind(this), 0
        @playlists = resp.items?.map (item) ->
          value: item.id
          label: item.name

  methods:
    toStore: ->
      for k in ['current', 'history']
        if this[k]
          try
            @$localStorage.set k, JSON.stringify this[k]

    fromStore: ->
      for k in ['current', 'playlist', 'history']
        if v = @$localStorage.get k
          try
            this[k] = JSON.parse v

    playlistChange: (val) ->
      @$localStorage.set 'playlist', if val then JSON.stringify(val) else null
      @playlist = val

    save: ->
      if @current.is_playing and (not @current.saved) and @playlist
        @current.saved = true
        @spotify "users/#{@authorized.id}/playlists/#{@playlist.value}/tracks",
          uris: [@current.item.uri]
        , (resp) =>
          @toStore

    poll: ->

      @spotify 'me/player/currently-playing', null, (resp) =>
        if @current and @current.item.id isnt resp.item.id
          @current.is_playing = false
          @history.unshift @current
          @current = null

        unless @current
          resp.saved = false
          resp.progress = 0
          @current = resp

        @current[k] = resp[k] for k in ['is_playing', 'progress_ms']
        @current.progress = @current.progress_ms / @current.item.duration_ms
        if @current.progress > 0.90
          @save()

        @toStore()
        setTimeout @poll.bind(this), 5000
      , (err) =>
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
  margin: 0 auto;
  float: none;

.current
  font-size: 130%
.playlists
  width: 30em
  display: inline-block
.usage
  margin-top: 20px
</style>
