<template lang="pug">
#app
  router-view
  footer
    hr
    a(href="https://github.com/brewingcode/auto-playlist")
      img(alt="GitHub logo" width="50" height="50" src="./assets/github.svg")
</template>

<style lang="stylus">
#app
  font-family 'Avenir', Helvetica, Arial, sans-serif
  -webkit-font-smoothing antialiased
  -moz-osx-font-smoothing grayscale
  text-align center
  color #2c3e50
  padding: 1em
</style>
