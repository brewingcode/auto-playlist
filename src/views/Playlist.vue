<template lang="pug">
div
  div
    router-link(to="/") back to home
    h3 Controls (ala vim)
    table.table-striped.controls
      thead
        tr
          th Key(s)
          th.text-center Action
      tbody
        tr(v-for="c in controls")
          td(style="font-family:monospace; padding-right:3ex;") {{c[0]}}
          td.text-center {{c[1]}}

  div(v-if="playlist")
    h1 Auto Playlist: {{ playlist.name }}
    h4(v-if="playlist.description" v-html="playlist.description")
    table.table.table-striped.table-sm.tracks(v-if="tracks.length")
      thead
        tr
          th.text-right(style="padding-right:2ex;") #
          th Title
          th Artist
          th Album
          th Added
      tbody
        tr(v-for="t,i in tracks"
          v-bind:class="{ active: t.selected, dupe: t.duplicate }"
          v-on:click="onClick")
          td.text-right(style="padding-right:2ex;") {{i+1}}
            span#trackIndex(style="display:none") {{i}}
          td.text-left {{t.track.name}}
          td.text-left {{allArtists(t)}}
          td.text-left {{t.track.album.name}}
          td.text-right(style="white-space:nowrap") {{humanize(t)}}
  b-modal(ref="cannot-play-modal" hide-footer title="Spotify Error")
    .text-center Sorry, can't play that track, it is unavailable.
</template>

<script lang="coffee">
import Spotify from '../mixins/spotify.coffee'
import Scroll from '../mixins/scroll.coffee'
import ignoreKey from '../ignore-key.coffee'
import { sortBy, findIndex } from 'lodash'
import { distanceInWordsToNow } from 'date-fns'

export default

  data: ->
    params: null
    playlist: null
    tracks: []
    error: null
    selectedIndex: 0
    controls: [
      [ 'j/down', 'next row/down one row' ]
      [ 'k/up', 'prev row/up one row' ]
      [ 'l/right', 'play track, or fast-forward if track is already playing' ]
      [ 'h/left', 'go back home' ]
      [ 'g', 'first row' ]
      [ 'G', 'last row' ]
      [ 'x', 'delete track from playlist' ]
    ]

  mixins: [ Spotify, Scroll ]

  mounted: ->
    @spotify "playlists/#{@$route.query.id}", null, (resp) => @playlist = resp
    @spotify "playlists/#{@$route.query.id}/tracks", null, @allTracks
    window.addEventListener 'keydown', @onKey

  beforeDestroy: ->
    window.removeEventListener 'keydown', @onKey

  computed:
    tracklist: -> sortBy @tracks, 'added_at'

  methods:
    allTracks: (resp) ->
      if resp.items.length is 0
        @error = 'No tracks found in playlist'
        return
      resp.items.forEach (i) -> i.selected = false
      if @tracks.length is 0
        resp.items[0].selected = true
      @tracks.push resp.items...
      @markDuplicates()
      if resp.next
        @spotify resp.next, null, @allTracks

    markDuplicates: ->
      history = {}
      @tracks.forEach (t) ->
        key = t.track.name + t.track.artists[0].name
        if history[key]
          t.duplicate = true
        else
          history[key] = 1
          t.duplicate = false

    allArtists: (t) ->
      t.track.artists.map (a) ->
        a.name
      .join ', '

    onKey: (e) ->
      if @tracks.length is 0
        @error = 'No tracks in playlist'
        return
      return if ignoreKey(e)

      if e.key in ['j', 'ArrowDown']
        @scrollDown @selectedIndex + 1
      else if e.key in ['k', 'ArrowUp']
        @scrollUp @selectedIndex - 1
      else if e.key is 'g'
        @scrollUp 0
        document.querySelector('body').scrollIntoView()
      else if e.key is 'G'
        @scrollDown @tracks.length - 1
      else if e.key is 'x'
        dead = @selectedIndex
        # console.log 'deleting:', @selectedIndex, @tracks[@selectedIndex].track.name
        @spotify "playlists/#{@playlist.id}/tracks",
          method: 'delete'
          data:
            tracks: [ { uri: @tracks[dead].track.uri } ]
        , =>
          @tracks.splice dead, 1
          @setCurrent dead - 1
      else if e.key in ['l', 'ArrowRight']
        @spotify 'me/player', null, (resp) =>
          if @tracks[@selectedIndex].track.id is resp.item?.id
            # currently playing, skip forward 30 seconds
            seekTo = resp.progress_ms + 30000
            @spotify 'me/player/seek',
              method: 'put'
              params:
                position_ms: seekTo
          else
            # not the currently playing track, start playing it
            @spotify "tracks/#{@tracks[@selectedIndex].track.id}?market=from_token", null, (resp) =>
              if resp.is_playable
                @spotify 'me/player/play',
                  method: 'put'
                  data:
                    context_uri: @playlist.uri
                    offset:
                      uri: @tracks[@selectedIndex].track.uri
              else
                @$refs['cannot-play-modal'].show()

      else if e.key in ['h', 'ArrowLeft']
        @$router.push '/'

    onClick: (e) ->
      el = e.target
      if el.tagName is 'TD'
        el = el.parentElement
      @selectedIndex = +el.querySelector('#trackIndex').innerText
      @setCurrent()

    humanize: (track) ->
      distanceInWordsToNow track.added_at, { addSuffix: true, includeSeconds: true }

</script>

<style lang="stylus">
tr.dupe
  color: red
tr.active
  background-color: #abefba !important
</style>
