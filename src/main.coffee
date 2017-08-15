import Vue from 'vue'
import App from './App.vue'

import VueResource from 'vue-resource'
import VueLS from 'vue-localstorage'
Vue.use VueResource
Vue.use VueLS

Vue.config.productionTip = false

new Vue
  el: '#app'
  render: (h) -> h(App)
