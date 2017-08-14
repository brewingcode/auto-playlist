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
      div {{t}}
  div(v-else)
    h3
      button(@click="auth") Authorize
</template>

<script lang="coffee">
import Vue from 'vue'
import VueResource from 'vue-resource'
import VueLS from 'vue-localstorage'

Vue.use VueResource
Vue.use VueLS

import Url from 'url'
import Querystring from 'querystring'
import Playlists from './Playlists.vue'
import Spotify from './spotify.coffee'

{ log } = console

self = ->
  window.location.protocol + '//' + window.location.host + '/'

export default
  name: 'app'

  data: ->
    tracks: []
    authorized: ''
    error: ''
    pollTimer: null

  mounted: ->
    me = Url.parse window.location.href, true
    if me.hash
      params = Querystring.parse me.hash.replace /^#/, ''
      if params.state is @$localStorage.get('csrf')
        @$localStorage.set 'access_token', params.access_token
      window.location.href = self()
    else if me.query
      if me.query.state is @$localStorage.get('csrf')
        @error = "Spotify authorization error: #{me.query.error}"

    if @$localStorage.get 'access_token'
      @spotify 'me', (resp) =>
        @authorized = "Hello, #{resp.id}"
        @pollTimer = setInterval =>
          @poll()
        , 5000

  methods:
    auth: ->
      @$localStorage.set 'csrf', 'something'

      url = Url.parse 'https://accounts.spotify.com/authorize'
      url.query =
        client_id: 'b07feecc7b624316b5742a3b2593f0e5'
        response_type: 'token'
        redirect_uri: self()
        state: @$localStorage.get 'csrf'
        scope: [
          'playlist-modify-public'
          'playlist-modify-private'
          'playlist-read-private'
          'playlist-read-collaborative'
        ].join ' '

      window.location.href = url.format()

    signOut: ->
      @$localStorage.remove 'access_token'
      window.location.reload()

    poll: ->
      @tracks.unshift(new Date())

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
