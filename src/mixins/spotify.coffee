# requires the following properties on the parent component:
#   - this.error (string)
#   - this.$localStorage (vue-localstorage library)
#   - this.$http (Vue built-in)

import crypto from 'crypto'
import Url from 'url'
import Querystring from 'querystring'

export default
  methods:
    self: ->
      window.location.protocol + '//' + window.location.host + window.location.pathname + '#/'

    checkAuthParams: (cb) ->
      me = Url.parse window.location.href, true
      if me.hash?.match /#\/access_token=/
        params = Querystring.parse me.hash.replace /^#\//, ''
        if params.state is @$localStorage.get('csrf')
          @$localStorage.set 'access_token', params.access_token
        @$localStorage.remove('csrf')
        @$router.push '/'
      else if me.query
        if me.query.state is @$localStorage.get('csrf')
          @error = "Spotify authorization error: #{me.query.error}"
        @$localStorage.remove('csrf')

      if @$localStorage.get 'access_token'
        @spotify 'me', null, cb

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
          'streaming'
        ].join ' '

      window.location.href = url.format()

    signOut: ->
      @$localStorage.remove 'access_token'
      @authorized = null
      @$router.push '/'

    spotify: (path, opts, cb) ->
      url = if path.match(/^http/) then path else "https://api.spotify.com/v1/#{path}"
      if not opts
        opts = {}
      opts.method = 'get' unless opts.method
      headers =
        'Authorization': "Bearer #{@$localStorage.get 'access_token'}"

      req = =>
        if opts.method is 'delete'
          @$http.delete url,
            body: JSON.stringify opts.data
            headers: headers
        else if opts.method is 'get'
          @$http.get url,
            headers: headers
        else
          opts.headers = headers
          @$http[opts.method] url, opts.data,
            opts

      @error = null
      req().then (response) ->
        if cb
          cb response.body
      , (err) =>
        if err.status is 401 and @$localStorage.get 'access_token'
          # our auth probably expired
          @$localStorage.remove 'access_token'
          @auth()
          # auth() will redirect (ie, return) us out of here

        if err.status isnt 0
          # only log error if status is NOT 0, because 0 indicates some weird
          # not-quite-errork
          console.error 'api error:', JSON.stringify(err)
          if msg = (err.body?.error?.message or err.statusText)
            @error = "#{err.status}: #{msg}"
          else
            @error = err.status
