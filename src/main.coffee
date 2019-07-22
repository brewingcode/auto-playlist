import Vue from 'vue'
import App from './App.vue'
import router from './router'

import VueResource from 'vue-resource'
import VueLS from 'vue-localstorage'
import BootstrapVue from 'bootstrap-vue'

Vue.use VueResource
Vue.use VueLS
Vue.use(BootstrapVue)

import '@babel/polyfill'
import 'mutationobserver-shim'
import 'vue-select/dist/vue-select.css'
import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

Vue.config.productionTip = false

new Vue
  router: router
  render: (h) -> h(App)
.$mount('#app')
