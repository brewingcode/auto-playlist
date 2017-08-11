<template lang="pug">
#app
  h1 Auto Playlist
  h2.error(v-if="error") Error: {{error}}
  h2 Tracks
  h3
    span(v-if="authorized") {{authorized}}
    button(v-else, @click="auth") Authorize
  ul(v-for="t in tracks")
    li {{t}}
</template>

<script lang="coffee">
import Vue from 'vue'
import VueResource from 'vue-resource'
import VueLS from 'vue-localstorage'

Vue.use VueResource
Vue.use VueLS

import Url from 'url'
import Querystring from 'querystring'

{ log } = console

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
    else if me.query
      if me.query.state is @$localStorage.get('csrf')
        @error = "Spotify authorization error: #{me.query.error}"

    @spotify 'me', (resp) =>
      @authorized = 'foo'
      resp.json().then (obj) =>
        @authorized = "Hello, #{obj.id}"
      @pollTimer = setInterval =>
        @poll()
      , 2000

  methods:
    spotify: (path, cb) ->
      @$http.get "https://api.spotify.com/v1/#{path}",
        headers:
          'Authorization': "Bearer #{@$localStorage.get 'access_token'}"
      .then cb, (err) ->
        @error = "Spotify API: #{err.statusText}"

    auth: ->
      @$localStorage.set 'csrf', 'something'

      url = Url.parse 'https://accounts.spotify.com/authorize'
      url.query =
        client_id: 'b07feecc7b624316b5742a3b2593f0e5'
        response_type: 'token'
        redirect_uri: window.location.href
        state: @$localStorage.get 'csrf'

      window.location.href = url.format()

    poll: ->
      @tracks.unshift(new Date())

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

ul
  list-style-type: none
  padding: 0

li
  display: inline-block
  margin: 0 10px

a
  color: #42b983
</style>
