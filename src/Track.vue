<template lang="pug">
.track
  span {{t.item.name}}
  span(v-if="t.saved")  saved to playlist!
  span(v-else)  unsaved...
</template>

<script lang="coffee">
export default
  props: ['t']
</script>
