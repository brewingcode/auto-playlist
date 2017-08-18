<template lang="pug">
.track
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
  div(v-if="t.is_playing")
    progress(:value="t.progress")
</template>

<script lang="coffee">
export default
  props: [ 't' ]
</script>
