<template lang="pug">
.playlists
  h3 Pick one of your playlists:
  v-select(:options="playlists")
</template>

<script lang="coffee">
import vSelect from 'vue-select'
import Spotify from './spotify.coffee'

export default
  name: 'x'
  data: ->
    playlists: []

  mounted: ->
    @spotify 'me/playlists', (resp) =>
      @playlists = resp.items?.map (item) ->
        value: item.id
        label: item.name

  components: { vSelect }
  mixins: [ Spotify ]
</script>

<style lang="stylus" scoped>
.playlists
  width: 30em
  display: inline-block
</style>
