<template lang="pug">
.track
  div
    span {{t.item.name}}
    span(v-if="t.saved")  saved to playlist!
    span(v-else)  unsaved...
  div(v-if="t.is_playing")
    progress(:value="t.progress")
</template>

<script lang="coffee">
export default
  props: [ 't' ]
</script>
