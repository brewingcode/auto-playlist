import crypto from 'crypto'
import Url from 'url'
import Querystring from 'querystring'

export default
  methods:
    self: ->
      window.location.protocol + '//' + window.location.host + '/'

    checkAuthParams: (cb) ->
      me = Url.parse window.location.href, true
      if me.hash
        params = Querystring.parse me.hash.replace /^#/, ''
        if params.state is @$localStorage.get('csrf')
          @$localStorage.set 'access_token', params.access_token
        window.location.href = @self()
      else if me.query
        if me.query.state is @$localStorage.get('csrf')
          @error = "Spotify authorization error: #{me.query.error}"

      if @$localStorage.get 'access_token'
        @spotify 'me', cb

    auth: ->
      @$localStorage.set 'csrf', crypto.randomBytes(12).toString('hex')

      url = Url.parse 'https://accounts.spotify.com/authorize'
      url.query =
        client_id: 'b07feecc7b624316b5742a3b2593f0e5'
        response_type: 'token'
        redirect_uri: @self()
        state: @$localStorage.get 'csrf'
        scope: [
          'playlist-modify-public'
          'playlist-modify-private'
          'playlist-read-private'
          'playlist-read-collaborative'
          'user-read-currently-playing'
          'user-read-playback-state'
        ].join ' '

      window.location.href = url.format()

    signOut: ->
      @$localStorage.remove 'access_token'
      window.location.reload()

    spotify: (path, cb) ->
      @$http.get "https://api.spotify.com/v1/#{path}",
        headers:
          'Authorization': "Bearer #{@$localStorage.get 'access_token'}"
      .then (response) ->
        response.json().then cb
      , (err) ->
        console.error 'api error:', err
        if err.status is 401 and @$localStorage.get 'access_token'
          # our auth probably expired
          @auth()
          # auth() will redirect (ie, return) us out of here
        @error = "Spotify API: #{err.statusText}"
