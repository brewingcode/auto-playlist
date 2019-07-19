<template lang="pug">
div
  h3.bg-danger(v-if="error") Error: {{error}}
  div(v-if="authorized")
    h4 Hello, {{authorized.id}}
    div
      button(@click="signOut") Sign Out
    .playlists
      h3 Destination playlist
      v-select(v-model="playlist", :options="playlists", @input="playlistChange")
      router-link(v-if="playlist" :to="{ name: 'playlist', query: { id: this.playlist.value } }") edit this playlist
    div(v-if="playlist")
      h2 Currently playing:
      div
        div(v-if="current && current.is_playing")
          SpotifyTrack.current(:t="current")
          div: button(@click="save") Save right now
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

</template>

<script lang="coffee">
import Spotify from '../mixins/spotify.coffee'
import vSelect from 'vue-select'
import SpotifyTrack from '../Track.vue' # "track" is a reserved html5 tag name
import ignoreKey from '../ignore-key.coffee'

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
    polling: null

  mounted: ->
    @fromStore()
    @checkAuthParams (resp) =>
      @authorized = resp
      @poll()
      @spotify 'me/playlists', null, (resp) =>
        @polling = setInterval @poll, 5000
        @playlists = resp.items?.map (item) ->
          value: item.id
          label: item.name
    window.addEventListener 'keydown', @onKey

  beforeDestroy: ->
    window.removeEventListener 'keydown', @onKey
    if @polling
      clearInterval @polling
      @polling = null

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
        @spotify "users/#{@authorized.id}/playlists/#{@playlist.value}/tracks",
          method: 'post'
          data:
            uris: [@current.item.uri]
        , (resp) =>
          @current.saved = true
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
      , (err) =>
        @error = 'Unable to get currently playing track'

    onKey: (e) ->
      return if ignoreKey(e)
      if e.key in ['l', 'ArrowRight']
        @$router.push
          name: 'playlist'
          query: id: @playlist.value

</script>

<style lang="stylus">
h2, h3, h4
  padding-top: 10px
.current
  font-size: 130%
.playlists
  width: 30em
  display: inline-block
.usage
  margin-top: 20px
.track-saved
  background-color: #abefba
</style>
