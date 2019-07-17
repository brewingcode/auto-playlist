<template lang="pug">
div
  h3.error(v-if="error") Error: {{error}}
  div(v-if="authorized")
    h4 Hello, {{authorized.id}}
    div
      button(@click="signOut") Sign Out
    .playlists
      h3 Destination playlist
      v-select(v-model="playlist", :options="playlists", :on-change="playlistChange")
      a(v-if="playlist" :href="'/playlist?id=' + this.playlist.value") edit this playlist
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

  footer
    hr
    a(href="https://github.com/brewingcode/auto-playlist")
      .github-logo
</template>

<script lang="coffee">
import Spotify from '../mixins/spotify.coffee'
import vSelect from 'vue-select'
import SpotifyTrack from '../Track.vue' # "track" is a reserved html5 tag name

export default
  components: { vSelect, SpotifyTrack }

  mixins: [ Spotify ]

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
          method: 'post'
          data:
            uris: [@current.item.uri]
        , (resp) =>
          @toStore

    poll: ->
      @spotify 'me/player/currently-playing', null, (resp) =>
        return unless resp

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

footer
  text-align: center
  .github-logo
     display: inline-block
     background-image: embedurl("../github-icon.svg", "utf8")
     background-size: cover
     height: (250px / 5)
     width: (256px / 5)
</style>
