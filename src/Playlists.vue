<template lang="pug">
.playlists
  h3 Pick one of your playlists:
  v-select(:options="playlists")
</template>

<script lang="coffee">
import vSelect from 'vue-select'

export default
  name: 'x'
  data: ->
    playlists: []

  mounted: ->
    @playlists = [
      { value: 'foo', label: 'This is foo' }
      { value: 'bar', label: 'This is bar' }
      { value: 'neo', label: 'This is the one' }
    ]

  components: {
    vSelect,
  }
</script>

<style lang="stylus" scoped>
.playlists
  width: 30em
  display: inline-block
</style>
