<template lang="pug">
.track(:class="{'track-saved': t.saved}")
  div
    a.title(target="_blank", :href="t.item.external_urls.spotify") {{t.item.name}}
    span
      |
      | by
      |
    a.artist(target="_blank", :href="t.item.artists[0].external_urls.spotify") {{t.item.artists[0].name}}
    span
      |
      | on
      |
    a.album(target="_blank", :href="t.item.album.external_urls.spotify") {{t.item.album.name}}

    span(v-if="!t.is_playing && t.saved && t.saved.constructor.name === 'String'") &nbsp;at&nbsp;
      span(:title="fmt(t)" v-html="humanize(t)")

  div(v-if="t.is_playing")
    progress(:value="t.progress")
    span &nbsp;{{ Math.round(t.progress*100, 0) }}%
</template>

<script lang="coffee">
import { parse, format, distanceInWordsToNow } from 'date-fns'

export default
  props: [ 't' ]
  methods:
    humanize: (track) ->
      distanceInWordsToNow parse(track.saved), { addSuffix: true, includeSeconds: true }
    fmt: (track) ->
      format parse track.saved

</script>

<style lang="stylus" scoped>
.track
  display: inline-block
  padding: 0 1em
  margin-bottom: 5px
span.progress
  font-size: smaller
</style>
