import Vue from 'vue'

import App from './App.vue'
import Playlist from './Playlist.vue'
NotFound = template: '<p>page not found</p>'

import VueResource from 'vue-resource'
import VueLS from 'vue-localstorage'
import BootstrapVue from 'bootstrap-vue/dist/bootstrap-vue.esm';

Vue.use VueResource
Vue.use VueLS
Vue.use BootstrapVue

import 'bootstrap-vue/dist/bootstrap-vue.css'
import 'bootstrap/dist/css/bootstrap.css'

Vue.config.productionTip = false

routes =
  '/': App
  '/playlist': Playlist

new Vue
  el: '#app'
  data:
    currentRoute: window.location.pathname
  computed:
    ViewComponent: -> routes[@currentRoute] or NotFound
  render: (h) -> h(@ViewComponent)
