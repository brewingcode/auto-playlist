<template lang="pug">
  #app
    h1 Auto Playlist
    h2 Tracks
    ul(v-for="t in tracks")
      li {{t}}
</template>

<script lang="coffee">
export default
  name: 'app'
  data: ->
    tracks: []
  mounted: ->
    console.log 'ready!'
    @load()
    @poll = setInterval =>
      @load()
    , 2000
  methods:
    load: ->
      console.log 'load!'
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
