export default
 methods:
  spotify: (path, cb) ->
    @$http.get "https://api.spotify.com/v1/#{path}",
      headers:
        'Authorization': "Bearer #{@$localStorage.get 'access_token'}"
    .then (response) =>
      response.json().then cb
    , (err) ->
      @error = "Spotify API: #{err.statusText}"
