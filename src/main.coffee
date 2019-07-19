import Vue from 'vue'
import App from './App.vue'
import router from './router'

import VueResource from 'vue-resource'
import VueLS from 'vue-localstorage'

Vue.use VueResource
Vue.use VueLS

import '@babel/polyfill'
import 'mutationobserver-shim'
import './plugins/bootstrap-vue'

import 'vue-select/dist/vue-select.css'

Vue.config.productionTip = false

new Vue
  router: router
  render: (h) -> h(App)
.$mount('#app')
