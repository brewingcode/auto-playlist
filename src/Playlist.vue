<template lang="pug">
  div Edit your playlist {{playlistId}} here!
</template>

<script lang="coffee">
export default
  data: ->
    params: new URLSearchParams(window.location.search)
  computed:
    playlistId: -> @params.get('id')
</script>
