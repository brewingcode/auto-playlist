import Vue from 'vue'
import Router from 'vue-router'
import Home from './views/Home.vue'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/access_token*',
      name: 'home',
      component: Home
    },
    {
      path: '/playlist',
      name: 'playlist',
      component: function () {
        return import(/* webpackChunkName: "playlist" */ './views/Playlist.vue')
      },
    },
  ],
})
